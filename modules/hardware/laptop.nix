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

  # Fingerprint reader (Synaptics 06cb:00f9, supported by libfprint).
  # fprintd enables fprintAuth on every PAM service by default; keep it only
  # where it is wanted (sudo, polkit-1). login and sddm must use the password
  # so the keyring unlocks; hyprlock talks to fprintd natively instead.
  services.fprintd.enable = true;
  security.pam.services = {
    login.fprintAuth = false;
    sddm.fprintAuth = false;
    hyprlock.fprintAuth = false; # also creates the "hyprlock" PAM service
  };
}
