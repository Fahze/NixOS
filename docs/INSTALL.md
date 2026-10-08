# Installation de NixOS (hôte `thinkpad-fahze`)

Guide pour installer l'hôte `thinkpad-fahze` sur le ThinkPad P14s Gen 5 AMD (disque unique de 1 To) :
chiffrement LUKS2, btrfs, GRUB (compatible avec un Windows installé plus tard) et secrets sops-nix.

> `install.sh` et `live-install.sh` viennent du dépôt d'origine et ne sont **pas** utilisables ici :
> l'installation se fait à la main, comme décrit ci-dessous.

**Résumé des étapes** : préparation (A) → partitionnement depuis le live USB (B) → clé de la machine
et secrets (C) → installation (D) → premier démarrage (E).

**Ne jamais** committer, coller ou envoyer `keys.txt` ni `ssh_host_ed25519_key` (clés privées),
ni la phrase de passe LUKS. Seules les clés publiques (`age1...`, `.pub`) circulent.

## Principe des secrets

- Le mot de passe de l'utilisateur `fahze` est stocké **chiffré** dans `secrets/secrets.yaml`
  (clé `user-password`, hash `yescrypt`). Le dépôt est public : seul le fichier chiffré est publié.
- Deux destinataires peuvent déchiffrer ce fichier :
  - ta **clé age personnelle** (`~/.config/sops/age/keys.txt` dans WSL), pour éditer les secrets ;
  - la **clé age de la machine**, dérivée de la clé SSH ed25519 de `root`
    (`/etc/ssh/ssh_host_ed25519_key`), pour les déchiffrer au démarrage.
- `sshd` est désactivé : NixOS **ne crée pas** la clé SSH de la machine. Elle est générée à la main
  pendant l'installation (étape C1).
- Le compte `root` est verrouillé (`hashedPassword = "!"`) : aucune connexion par mot de passe.
  L'élévation passe par `sudo` (groupe `wheel`).
- Comme `users.mutableUsers = false`, `passwd` n'a aucun effet durable : pour changer le mot de
  passe, modifie le secret (étape A3) puis reconstruis le système.

## A. Préparation

### A1. Machine et clé USB

1. Si possible, mets le BIOS à jour avant d'effacer le disque (Lenovo Vantage / Windows Update sous Windows).
2. Dans le BIOS : mode **UEFI**, **Secure Boot désactivé**. Le démarrage se fait avec **F12**.
3. Prépare un live USB NixOS (ISO « Graphical » ou « Minimal », 64 bits) avec Rufus (mode GPT/UEFI,
   écriture en mode **DD** si Rufus le propose) ou `dd`.

### A2. Clé age personnelle (WSL, une seule fois)

```bash
mkdir -p ~/.config/sops/age
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt   # affiche la clé PUBLIQUE
```

Sauvegarde `keys.txt` dans un gestionnaire de mots de passe : sans elle, tu ne peux plus modifier
les secrets. La clé publique est déjà dans `.sops.yaml`.

### A3. Créer (ou changer) le secret du mot de passe (WSL)

Depuis la racine du dépôt :

```bash
mkdir -p secrets
HASH=$(nix shell nixpkgs#mkpasswd -c mkpasswd -m yescrypt)    # demande le mot de passe
printf 'user-password: "%s"\n' "$HASH" > secrets/secrets.yaml
nix shell nixpkgs#sops -c sops --encrypt --in-place secrets/secrets.yaml
nix shell nixpkgs#sops -c sops --decrypt secrets/secrets.yaml  # vérification (affiche le hash)
git add secrets/secrets.yaml                                   # Nix ne voit que les fichiers suivis
```

Pour changer le mot de passe plus tard : `nix shell nixpkgs#sops -c sops secrets/secrets.yaml`,
remplace le hash, commit, puis rebuild.

## B. Partitionnement (depuis le live USB)

> **Étape destructive** : elle efface tout le disque. Sauvegarde ce qui doit l'être avant.

Disposition prévue (disque d'environ 931 GiB) :

| Partition | Taille | Contenu |
| --- | --- | --- |
| 1 — `ESP` | 1 GiB | FAT32, montée sur `/boot` (noyaux, initrd, GRUB) |
| 2 — `cryptroot` | ~580 GiB | LUKS2 → btrfs (sous-volumes `@`, `@home`, `@nix`) |
| (libre) | ~350 GiB | **Non alloué**, réservé à un Windows éventuel |

`/boot` est sur l'ESP non chiffrée : GRUB n'a donc pas à déverrouiller le LUKS (pas de souci avec
l'algorithme argon2id de LUKS2), et `os-prober` pourra détecter un Windows installé plus tard.
Comme l'ESP fait 1 GiB, Windows pourra la réutiliser.

### B1. Réseau et disque

Ouvre un terminal, connecte-toi au réseau (`nmcli device wifi connect <SSID> --ask` ou câble), puis :

```bash
sudo -i
lsblk -o NAME,SIZE,MODEL,TYPE        # repère le disque NVMe interne (souvent /dev/nvme0n1)
DISK=/dev/nvme0n1                    # <-- vérifie ce nom avant de continuer !
```

### B2. Tables de partitions

```bash
sgdisk --zap-all "$DISK"
sgdisk -n1:0:+1G   -t1:ef00 -c1:ESP       "$DISK"
sgdisk -n2:0:+580G -t2:8309 -c2:cryptroot "$DISK"
sgdisk -p "$DISK"                    # vérification : ~350 GiB restent libres
partprobe "$DISK"
```

### B3. LUKS2 et systèmes de fichiers

```bash
cryptsetup luksFormat --type luks2 /dev/disk/by-partlabel/cryptroot   # choisis une phrase de passe solide
cryptsetup open /dev/disk/by-partlabel/cryptroot cryptroot

mkfs.fat -F 32 -n ESP /dev/disk/by-partlabel/ESP
mkfs.btrfs -L nixos /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt
```

### B4. Montage

```bash
OPTS=compress=zstd,noatime
mount -o subvol=@,$OPTS     /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{home,nix,boot}
mount -o subvol=@home,$OPTS /dev/mapper/cryptroot /mnt/home
mount -o subvol=@nix,$OPTS  /dev/mapper/cryptroot /mnt/nix
mount /dev/disk/by-partlabel/ESP /mnt/boot
lsblk -f                             # vérification
```

## C. Clé de la machine et secrets

### C1. Générer la clé (live USB)

```bash
mkdir -p /mnt/etc/ssh
ssh-keygen -t ed25519 -N "" -f /mnt/etc/ssh/ssh_host_ed25519_key
chmod 600 /mnt/etc/ssh/ssh_host_ed25519_key
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#ssh-to-age -c ssh-to-age < /mnt/etc/ssh/ssh_host_ed25519_key.pub
```

La dernière commande affiche la clé age **publique** de la machine (`age1...`). Note-la.
La clé privée reste sur le disque de la machine (chiffré par LUKS).

### C2. Ajouter la machine comme destinataire (WSL, avec ta clé personnelle)

Dans `.sops.yaml`, décommente les deux lignes `thinkpad-fahze` et remplace `age1...` par la clé
de l'étape C1, puis :

```bash
nix shell nixpkgs#sops -c sops updatekeys secrets/secrets.yaml
git add .sops.yaml secrets/secrets.yaml
git commit -m "chore(secrets): add thinkpad-fahze as sops recipient"
git push
```

(`sops` n'est pas disponible dans le live USB : cette étape se fait depuis WSL, où se trouve ta
clé personnelle.)

## D. Installation

### D1. Récupérer le dépôt

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
nix shell nixpkgs#git
git clone https://github.com/Fahze/NixOS.git ~/NixOS     # dans le live USB (éphémère)
cd ~/NixOS
git checkout feat/thinkpad-fahze        # ou main une fois la branche fusionnée
```

### D2. Générer `hardware-configuration.nix`

```bash
nixos-generate-config --root /mnt --show-hardware-config > hosts/thinkpad-fahze/hardware-configuration.nix
```

Ce fichier remplace le placeholder du dépôt. Ouvre-le et vérifie :

- `boot.initrd.luks.devices."cryptroot"` est présent (UUID de la partition `cryptroot`) ;
- les `fileSystems` `/`, `/home`, `/nix` (sous-volumes `@`, `@home`, `@nix`) et `/boot` (vfat) existent ;
- ajoute les options de montage btrfs aux trois sous-volumes, par exemple :

```nix
fileSystems."/".options = [ "subvol=@" "compress=zstd" "noatime" ];
fileSystems."/home".options = [ "subvol=@home" "compress=zstd" "noatime" ];
fileSystems."/nix".options = [ "subvol=@nix" "compress=zstd" "noatime" ];
```

(si le fichier généré contient déjà ces `options`, complète-les plutôt que de les redéfinir).

Puis **suis le fichier avec git** (Nix ne voit que les fichiers suivis) :

```bash
git add hosts/thinkpad-fahze/hardware-configuration.nix

# Garde une copie sur le disque : le live USB sera perdu au redémarrage (voir E4)
mkdir -p /mnt/etc/nixos
cp hosts/thinkpad-fahze/hardware-configuration.nix /mnt/etc/nixos/
```

### D3. Installer

```bash
nixos-install --flake .#thinkpad-fahze --no-root-passwd
```

`--no-root-passwd` : `root` est verrouillé, l'installateur ne doit pas demander de mot de passe.
Quand c'est terminé : `umount -R /mnt`, `cryptsetup close cryptroot`, retire la clé USB, `reboot`.

Pense ensuite à committer le `hardware-configuration.nix` définitif depuis le système installé
(étape E4), pour que le dépôt corresponde à la machine.

## E. Premier démarrage

### E1. Connexion

Saisis la phrase de passe LUKS, puis connecte-toi avec `fahze` et le mot de passe choisi à l'étape A3.
Vérifie : `sudo -v` et `ls /run/secrets-for-users/`.

### E2. Empreinte digitale

Le lecteur est géré par `fprintd` (utilisé pour `sudo` et pour `hyprlock`, pas pour SDDM ni `login`).

```bash
fprintd-list fahze                   # empreintes déjà enregistrées (peut être vide)
fprintd-delete fahze                 # optionnel : repartir de zéro si d'anciennes empreintes existent
fprintd-enroll fahze                 # touche le capteur plusieurs fois (idéalement 2 doigts)
fprintd-verify fahze                 # vérification
```

### E3. Liste de contrôle

- Touchpad : défilement naturel, tap-to-click, désactivation pendant la frappe.
- Écran : `hypridle` éteint l'écran (`hyprctl dispatch dpms off`) puis le rallume à la reprise.
- Veille : fermer le capot suspend sur batterie, verrouille sur secteur, ne fait rien en station d'accueil.
- Clavier : disposition `gb` (extd) puis `fr` (bascule `Alt+Shift`) dans Hyprland, SDDM et hyprlock.
- Batterie : `sudo tlp-stat -b` (seuils 82/90) et `sudo tlp-stat -p` (profil `amd-pstate`, EPP).
- Docker : `docker run --rm hello-world` et `docker compose version`.
- Outils : `node --version`, `rustc --version`, `SUPER+C` (VS Code).
- Thème : GTK/Qt, kitty, waybar, hyprlock et rofi en Catppuccin Macchiato / mauve.
- Firmware : `fwupdmgr get-updates`.

### E4. Fixer le dépôt

Le dépôt cloné dans le live USB a disparu. Clone-le dans `~/NixOS` (le script `rebuild` le cherche
là) et récupère la copie du `hardware-configuration.nix` laissée dans `/etc/nixos` :

```bash
git clone https://github.com/Fahze/NixOS.git ~/NixOS
cp /etc/nixos/hardware-configuration.nix ~/NixOS/hosts/thinkpad-fahze/
cd ~/NixOS && git add hosts/thinkpad-fahze/hardware-configuration.nix
git commit -m "feat(hosts): add the generated hardware configuration" && git push
rebuild
```

## Limites et récupération

- Le dépôt est public : le fichier chiffré est visible de tous. La sécurité repose sur les clés.
- Perte de la clé de la machine : régénère-la, puis refais les étapes C1 et C2.
- Perte de la clé personnelle : tu ne peux plus modifier `secrets.yaml`. La machine le lit encore ;
  recrée une clé personnelle, puis réécris le secret depuis un système qui peut le déchiffrer.
- `root` étant verrouillé, le mode de secours n'accepte plus de mot de passe root. En cas de
  problème, démarre un live USB, monte le disque (`cryptsetup open` + `mount`), `nixos-enter`,
  corrige la configuration.
- Phrase de passe LUKS perdue : les données sont irrécupérables. Note-la dans un gestionnaire de mots de passe.
