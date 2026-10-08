{ pkgs, ... }:
{
  # environment.systemPackages = with pkgs; [ hypridle ];
  home-manager.sharedModules = [
    (_: {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            ignore_dbus_inhibit = false;
            lock_cmd = "pidof hyprlock || hyprlock";
            unlock_cmd = "pkill --signal SIGUSR1 hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = [
            {
              timeout = 600; # 10 minutes: lock
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 900; # 15 minutes: screen off
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 1800; # 30 minutes: suspend
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
    })
  ];
}
