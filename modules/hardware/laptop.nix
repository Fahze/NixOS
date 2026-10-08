{ config, lib, ... }:
{
  # Firmware updates (LVFS) and CPU microcode
  services.fwupd.enable = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Battery information (used by the batterynotify script)
  services.upower.enable = true;

  # Lid and power key. The power key also hosts the fingerprint reader, so a
  # short press only suspends and a long press powers off.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };
}
