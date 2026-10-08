{
  host,
  lib,
  pkgs,
  ...
}:
let
  palette = import ../palette.nix { inherit host lib; };
  variant = palette.flavor;
  inherit (palette) accent isDark;
  catppuccin-kvantum-pkg = pkgs.catppuccin-kvantum.override { inherit variant accent; };
  catppuccin = "catppuccin-${variant}-${accent}";
in
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        home.packages = [ catppuccin-kvantum-pkg ];

        qt = {
          enable = true;
          platformTheme.name = "gtk3";
          style.name = "kvantum";
        };
        gtk = {
          enable = true;
          gtk2.force = true;
          theme = {
            name = "${catppuccin}-compact";
            package = pkgs.catppuccin-gtk.override {
              variant = variant;
              accents = [ accent ];
              size = "compact";
            };
          };
          iconTheme = {
            # package = pkgs.adwaita-icon-theme;
            # name = "Adwaita";
            package = pkgs.papirus-icon-theme;
            name = if isDark then "Papirus-Dark" else "Papirus-Light";
          };
          gtk3.extraConfig = {
            "gtk-application-prefer-dark-theme" = if isDark then "1" else "0";
          };
          gtk4.extraConfig = {
            "gtk-application-prefer-dark-theme" = if isDark then "1" else "0";
          };
        };

        home.sessionVariables = {
          ADW_COLOR_SCHEME = if isDark then "prefer-dark" else "prefer-light"; # Libadwaita
        };

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = if isDark then "prefer-dark" else "prefer-light";
          };
        };

        home.pointerCursor = {
          enable = true;
          gtk.enable = true;
          x11.enable = true;
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 24;
        };

        xdg.configFile = {
          "gtk-4.0/assets" = {
            force = true;
            source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
          };
          "gtk-4.0/gtk.css" = {
            force = true;
            source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
          };
          "gtk-4.0/gtk-dark.css" = {
            force = true;
            source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
          };
          "Kvantum/${catppuccin}".source = "${catppuccin-kvantum-pkg}/share/Kvantum/${catppuccin}";
          "Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
            General.theme = catppuccin;
          };
        };
      }
    )
  ];
}
