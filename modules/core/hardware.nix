{ pkgs, host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) hostname bluetoothSupport;
in
{
  programs.solaar.enable = false; # disabled: no Logitech receiver
  hardware = {
    sane = {
      enable = false; # disabled: no scanner
      extraBackends = [ pkgs.sane-airscan ];
      disabledDefaultBackends = [ "escl" ];
    };
    logitech.wireless.enable = false;
    graphics.enable = true;
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = false; # disabled: no QMK keyboard
    bluetooth = {
      enable = bluetoothSupport;
      powerOnBoot = bluetoothSupport;
      settings = {
        General = {
          Name = hostname;
          ControllerMode = "dual";
          FastConnectable = true;
          Experimental = true;
          KernelExperimental = true;
          JustWorksRepairing = "always";
          SecureConnections = "on";
        };
        GATT = {
          Cache = "always";
          Channels = 3;
        };
        Policy = {
          AutoEnable = true;
          ReconnectAttempts = 7;
          ReconnectIntervals = "1,2,4,8,16,32,64";
          ResumeDelay = 1;
        };
      };
    };
  };
}
