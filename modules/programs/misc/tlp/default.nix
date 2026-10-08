{ ... }:
{
  services.tlp = {
    enable = true;
    settings = {
      # amd-pstate (Zen 2+, kernel >= 6.3). In "active" mode only the
      # performance/powersave governors exist; power vs. performance is steered by EPP.
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # Firmware platform profile (see `tlp-stat -p` for what the P14s offers)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "balanced";

      # Protect battery (single battery: BAT0 only)
      START_CHARGE_THRESH_BAT0 = 82;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };
}
