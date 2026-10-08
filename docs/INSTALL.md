# Installation de NixOS (hôte `thinkpad-fahze`)

> Document en cours de rédaction. Cette version décrit le **bootstrap des secrets**
> (sops-nix, compte `root` verrouillé). Le partitionnement, `nixos-generate-config`
> et l'enrôlement de l'empreinte seront ajoutés avec le nettoyage du fork.

## Principe

- Le mot de passe de l'utilisateur `fahze` est stocké **chiffré** dans `secrets/secrets.yaml`
  (clé `user-password`, hash `yescrypt`). Le dépôt est public : seul le fichier chiffré est publié.
- Deux destinataires peuvent déchiffrer ce fichier :
  - ta **clé age personnelle** (`~/.config/sops/age/keys.txt` dans WSL), pour éditer les secrets ;
  - la **clé age de la machine**, dérivée de la clé SSH ed25519 de `root`
    (`/etc/ssh/ssh_host_ed25519_key`), pour les déchiffrer au démarrage.
- `sshd` est désactivé : NixOS **ne crée pas** la clé SSH de la machine. Elle est générée à la main
  pendant l'installation (étape 3).
- Le compte `root` est verrouillé (`hashedPassword = "!"`) : aucune connexion par mot de passe.
  L'élévation passe par `sudo` (groupe `wheel`).
- Comme `users.mutableUsers = false`, `passwd` n'a aucun effet durable : pour changer le mot de
  passe, modifie le secret (étape 2) puis reconstruis le système.

**Ne jamais** committer, coller ou envoyer `keys.txt` ni `ssh_host_ed25519_key` (clés privées).
Seules les clés publiques (`age1...`, `.pub`) circulent.

## 1. Clé age personnelle (WSL, une seule fois)

```bash
mkdir -p ~/.config/sops/age
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt   # affiche la clé PUBLIQUE
```

Sauvegarde `keys.txt` dans un gestionnaire de mots de passe : sans elle, tu ne peux plus modifier
les secrets. La clé publique est déjà dans `.sops.yaml`.

## 2. Créer (ou changer) le secret du mot de passe (WSL)

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

## 3. Clé de la machine (pendant l'installation, live USB)

Après avoir monté la cible dans `/mnt` :

```bash
mkdir -p /mnt/etc/ssh
ssh-keygen -t ed25519 -N "" -f /mnt/etc/ssh/ssh_host_ed25519_key
chmod 600 /mnt/etc/ssh/ssh_host_ed25519_key
nix shell nixpkgs#ssh-to-age -c ssh-to-age < /mnt/etc/ssh/ssh_host_ed25519_key.pub
```

La dernière commande affiche la clé age **publique** de la machine (`age1...`). Note-la.
La clé privée reste sur le disque de la machine (chiffré par LUKS).

## 4. Ajouter la machine comme destinataire (WSL, avec ta clé personnelle)

Dans `.sops.yaml`, décommente les deux lignes `thinkpad-fahze` et remplace `age1...` par la clé
de l'étape 3, puis :

```bash
nix shell nixpkgs#sops -c sops updatekeys secrets/secrets.yaml
git add .sops.yaml secrets/secrets.yaml
git commit -m "chore(secrets): add thinkpad-fahze as sops recipient"
git push
```

(`sops` n'est pas disponible dans le live USB : cette étape se fait depuis WSL, où se trouve ta
clé personnelle.)

## 5. Installer

Dans le live USB, récupère la dernière version du dépôt, copie le
`hardware-configuration.nix` généré (`nixos-generate-config --root /mnt`) vers
`hosts/thinkpad-fahze/`, `git add` ce fichier, puis :

```bash
nixos-install --flake .#thinkpad-fahze --no-root-passwd
```

`--no-root-passwd` : `root` est verrouillé, l'installateur ne doit pas demander de mot de passe.

## 6. Premier démarrage

- Connexion avec `fahze` et le mot de passe choisi à l'étape 2.
- Vérifier : `sudo -v`, `ls /run/secrets-for-users/`.

## Limites et récupération

- Le dépôt est public : le fichier chiffré est visible de tous. La sécurité repose sur les clés.
- Perte de la clé de la machine : régénère-la, puis refais les étapes 3 et 4.
- Perte de la clé personnelle : tu ne peux plus modifier `secrets.yaml`. La machine le lit encore ;
  recrée une clé personnelle, puis réécris le secret depuis un système qui peut le déchiffrer.
- `root` étant verrouillé, le mode de secours n'accepte plus de mot de passe root. En cas de
  problème, démarre un live USB, monte le disque, `nixos-enter`, corrige la configuration.
