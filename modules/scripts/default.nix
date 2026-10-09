{
  pkgs,
  lib,
  host,
  config,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) terminal waybarTheme;
  waybarSwitch = pkgs.callPackage ../desktop/hyprland/scripts/waybar-switch.nix {
    inherit waybarTheme;
  };
in
let
  # Define your custom args once
  scriptArgs = {
    inherit
      host
      pkgs
      lib
      config
      terminal
      waybarSwitch
      ;
  };

  scripts = [
    (import ./rebuild.nix scriptArgs)
    (import ./rollback.nix scriptArgs)
    (import ./launcher.nix scriptArgs)
    (import ./network.nix scriptArgs)
    (import ./tmux-sessionizer.nix scriptArgs)
    (import ./extract.nix scriptArgs)
    (import ./driverinfo.nix scriptArgs)
    # Add new scripts here as you create them
  ];
in
{
  environment.systemPackages = scripts;
}
