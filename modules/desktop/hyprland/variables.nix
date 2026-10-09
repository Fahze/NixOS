{
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe;
  vars = import ../../../hosts/${host}/variables.nix;
  palette = import ../../themes/palette.nix { inherit host lib; };
  inherit (vars)
    bar
    browser
    terminal
    editor
    fileManager
    kbdLayout
    kbdVariant
    capslockAsESC
    defaultWallpaper
    waybarTheme
    ;
  kbdOptions = vars.kbdOptions or "";

  # Command run by SUPER + C: GUI editors directly, terminal editors inside the terminal.
  editorCommands = {
    vscode = "code";
    zed = "zeditor";
    helix = "${terminal} -e hx";
    neovim = "${terminal} -e nvim";
    nixvim = "${terminal} -e nvim";
    nvchad = "${terminal} -e nvim";
    doom-emacs = "emacs";
  };
  editorCommand = editorCommands.${editor} or "code";

  # Import script modules
  # autowaybar = pkgs.callPackage ./scripts/autowaybar.nix { };
  autoclicker = pkgs.callPackage ./scripts/autoclicker.nix { };
  batterynotify = pkgs.callPackage ./scripts/batterynotify.nix { };
  clipmanager = pkgs.callPackage ./scripts/clipmanager.nix { };
  fileManagerScript = pkgs.callPackage ./scripts/file-manager.nix { inherit terminal; };
  gamemode = pkgs.callPackage ./scripts/gamemode.nix { };
  keyboardswitch = pkgs.callPackage ./scripts/keyboardswitch.nix { };
  keybinds-yad = pkgs.callPackage ./scripts/keybinds-yad.nix { };
  # keybinds-rofi = pkgs.callPackage ./scripts/keybinds-yad.nix { };
  # mediactrl = pkgs.callPackage ./scripts/mediactrl.nix { };
  launcher = pkgs.callPackage ../../scripts/launcher.nix { inherit lib pkgs terminal; };
  rofimusic = pkgs.callPackage ./scripts/rofimusic.nix { };
  screen-record = pkgs.callPackage ./scripts/screen-record.nix { };
  screenshot = pkgs.callPackage ./scripts/screenshot.nix { };
  wallpaper = pkgs.callPackage ./scripts/wallpaper.nix { inherit defaultWallpaper; };
  waybarSwitch = pkgs.callPackage ./scripts/waybar-switch.nix { inherit waybarTheme; };
  zoom = pkgs.callPackage ./scripts/zoom.nix { };
in
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        # So `waybar-switch <theme>` can be run by hand from a terminal.
        home.packages = [ waybarSwitch ];

        xdg.configFile."hypr/variables.lua" = {
          text = ''
            -- Scripts
            autoclicker = "${getExe autoclicker}"
            batterynotify = "${getExe batterynotify}"
            clipmanager = "${getExe clipmanager}"
            fileManagerScript = "${getExe fileManagerScript}"
            gamemode = "${getExe gamemode}"
            keyboardswitch = "${getExe keyboardswitch}"
            keybinds_yad = "${getExe keybinds-yad}"
            rofimusic = "${getExe rofimusic}"
            screen_record = "${getExe screen-record}"
            screenshot = "${getExe screenshot}"
            wallpaper = "${getExe wallpaper}"
            zoom = "${getExe zoom}"

            mainMod = "SUPER"
            launcher = "${getExe launcher}"
            bar = "${
              if bar == "wayle" then
                "wayle shell"
              else if bar == "waybar" then
                getExe waybarSwitch
              else
                bar
            }"
            term = "${terminal}"
            editor = "${editorCommand}"
            browser = "${browser}"
            fileManager = "${fileManager}"
            capslockAsESC = ${lib.boolToString capslockAsESC}
            kbdLayout = "${kbdLayout}"
            kbdVariant = "${kbdVariant}"
            kbdOptions = "${kbdOptions}"

            -- Theme (Catppuccin ${palette.flavorCap}, accent ${palette.accent})
            activeBorderStart = "rgba(${palette.accentColor}ff)"
            activeBorderEnd = "rgba(${palette.colors.rosewater}ff)"
            inactiveBorderStart = "rgba(${palette.colors.lavender}cc)"
            inactiveBorderEnd = "rgba(${palette.colors.overlay0}cc)"
          '';
        };
      }
    )
  ];
}
