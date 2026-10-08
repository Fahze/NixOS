{ config, lib, ... }:
{
  # Firmware updates (LVFS) and CPU microcode
  services.fwupd.enable = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Battery information (used by the batterynotify script)
  services.upower.enable = true;
}
