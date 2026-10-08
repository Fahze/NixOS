# PLACEHOLDER — remplacé à l'installation par la sortie de `nixos-generate-config`
#
# Ce fichier n'existe que pour permettre l'évaluation de l'hôte avant l'installation
# (`nix eval .#nixosConfigurations.thinkpad-fahze...`). Il ne doit JAMAIS être activé
# sur la machine : à l'installation, copier le fichier généré par
# `nixos-generate-config --root /mnt` par-dessus celui-ci.
{ ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  # Systèmes de fichiers factices (évaluation uniquement)
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };
}
