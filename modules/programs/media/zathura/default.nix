{ host, lib, ... }:
let
  palette = import ../../../themes/palette.nix { inherit host lib; };
in
{
  home-manager.sharedModules = [
    (_: {
      programs.zathura = {
        enable = true;
        options = {
          selection-clipboard = "clipboard";
          recolor = false; # toggle with Ctrl+R
          recolor-keephue = true;

          default-bg = palette.hex.base;
          default-fg = palette.hex.text;
          statusbar-bg = palette.hex.mantle;
          statusbar-fg = palette.hex.text;
          inputbar-bg = palette.hex.mantle;
          inputbar-fg = palette.hex.text;
          notification-bg = palette.hex.mantle;
          notification-fg = palette.hex.text;
          notification-error-bg = palette.hex.mantle;
          notification-error-fg = palette.hex.red;
          notification-warning-bg = palette.hex.mantle;
          notification-warning-fg = palette.hex.yellow;
          highlight-color = palette.hex.yellow;
          highlight-active-color = palette.accentHex;
          completion-bg = palette.hex.surface0;
          completion-fg = palette.hex.text;
          completion-highlight-bg = palette.accentHex;
          completion-highlight-fg = palette.hex.base;
          recolor-lightcolor = palette.hex.base;
          recolor-darkcolor = palette.hex.text;
        };
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications."application/pdf" = "org.pwmt.zathura.desktop";
      };
    })
  ];
}
