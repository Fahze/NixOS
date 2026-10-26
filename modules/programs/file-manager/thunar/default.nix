{ pkgs, host, ... }:
let
  inherit (import ../../../../hosts/${host}/variables.nix) terminal;
in
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin # Archive management
      thunar-volman # Volume management (automount removable devices)
      thunar-media-tags-plugin # Tagging & renaming feature for media files
    ];
  };
  # Archive manager
  environment.systemPackages = with pkgs; [ file-roller ];

  home-manager.sharedModules = [
    (_: {
      # exo-open --launch TerminalEmulator (Thunar's "Open Terminal Here") needs
      # an XFCE helper descriptor; nothing provides one outside XFCE proper.
      xdg.configFile."xfce4/helpers.rc".text = "TerminalEmulator=${terminal}\n";
      xdg.dataFile."xfce4/helpers/${terminal}.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Type=X-XFCE-Helper
        Name=${terminal}
        Icon=${terminal}
        StartupNotify=false
        X-XFCE-Binaries=${terminal};
        X-XFCE-Category=TerminalEmulator
        X-XFCE-Commands=%B;
        X-XFCE-CommandsWithParameter=%B %s;
      '';
    })
  ];
}
