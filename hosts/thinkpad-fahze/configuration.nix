{ lib, ... }:
let
  vars = import ./variables.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./host-packages.nix

    # Core Modules (Be careful here)
    ../../modules/scripts
    ../../modules/core/boot.nix
    ../../modules/core/bash.nix
    ../../modules/core/zsh.nix
    ../../modules/core/starship.nix
    ../../modules/core/fonts.nix
    ../../modules/core/hardware.nix
    ../../modules/core/network.nix
    ../../modules/core/netbird.nix # Ynov VPN (temporary)
    ../../modules/core/nh.nix
    ../../modules/core/packages.nix
    ../../modules/core/printing.nix
    ../../modules/core/sddm.nix
    ../../modules/core/security.nix
    ../../modules/core/services.nix
    ../../modules/core/storage.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix
    ../../modules/core/xdg.nix
    # ../../modules/core/syncthing.nix
    # ../../modules/core/jellyfin.nix
    # ../../modules/core/dlna.nix
    # ../../modules/core/flatpak.nix
    # ../../modules/core/virtualisation.nix

    # Optional
    # ../../modules/hardware/drives # My personal drives
    ../../modules/hardware/laptop.nix
    ../../modules/dev/docker.nix
    ../../modules/dev/languages.nix
    ../../modules/hardware/video/${vars.videoDriver}.nix
    ../../modules/desktop/${vars.desktop}
    ../../modules/programs/browser/${vars.browser}
    ../../modules/programs/terminal/${vars.terminal}
    ../../modules/programs/editor/vscode # default editor (editor = "vscode")
    ../../modules/programs/editor/zed
    ../../modules/programs/editor/neovim
    ../../modules/programs/file-manager/${vars.fileManager}
    ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/lazygit
    ../../modules/programs/cli/btop
    # ../../modules/programs/cli/cava
    # ../../modules/programs/cli/fastfetch
    ../../modules/programs/media/discord
    ../../modules/programs/media/spicetify
    ../../modules/programs/media/zathura
    # ../../modules/programs/media/youtube-music
    # ../../modules/programs/media/thunderbird
    # ../../modules/programs/media/obs-studio
    ../../modules/programs/media/mpv
    ../../modules/programs/misc/tlp
    # ../../modules/programs/misc/lact # GPU fan, clock and power configuration
  ]
  ++ lib.optional (vars.games == true) ../../modules/core/games.nix;
}
