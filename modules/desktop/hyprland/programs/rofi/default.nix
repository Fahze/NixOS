{
  pkgs,
  lib,
  host,
  ...
}:
let
  inherit (import ../../../../../hosts/${host}/variables.nix) terminal;
  palette = import ../../../../themes/palette.nix { inherit host lib; };
in
{
  home-manager.sharedModules = [
    (_: {
      programs.rofi = {
        enable = true;
        settings = import ./config.nix { inherit terminal lib pkgs; };
        plugins = with pkgs; [
          rofi-emoji # https://github.com/Mange/rofi-emoji 🤯
          rofi-games # https://github.com/Rolv-Apneseth/rofi-games 🎮
        ];
      };
      xdg.configFile."rofi/launchers" = {
        source = ./launchers;
        recursive = true;
      };
      xdg.configFile."rofi/colors" = {
        source = ./colors;
        recursive = true;
      };
      # Generated from the central palette (the other color files stay static).
      xdg.configFile."rofi/colors/catppuccin.rasi".text = ''
        * {
            background:     ${palette.hex.base}ff;
            background-alt: ${palette.hex.surface0}ff;
            foreground:     ${palette.hex.text}ff;
            selected:       ${palette.accentHex}ff;
            active:         ${palette.hex.green}ff;
            urgent:         ${palette.hex.red}ff;
        }
      '';
    })
  ];
}
