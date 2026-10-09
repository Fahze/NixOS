{ ... }:
{
  # TRIM real blocks through LUKS (tradeoff: a disk-level observer can tell
  # which blocks are in use) and skip the dm-crypt read/write workqueues for
  # lower NVMe latency (requires kernel >= 5.9, effective after a reboot).
  boot.initrd.luks.devices."cryptroot" = {
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  # No swap partition today (swapDevices = [ ] in hardware-configuration.nix).
  # No hibernation planned.
  zramSwap.enable = true;

  # services.fstrim.enable is already set in modules/core/services.nix.
  services.btrfs.autoScrub.enable = true;

  # /home only: @ (root) is a separate subvolume from @nix, and a rollback of
  # / would be inconsistent with the NixOS generations that already cover it.
  # Requires the nested subvolume to exist first (one-time, manual):
  #   sudo btrfs subvolume create /home/.snapshots
  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    ALLOW_USERS = [ "fahze" ];
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 6;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 6;
    TIMELINE_LIMIT_YEARLY = 0;
  };
}
