{ host, lib, ... }:
let
  palette = import ../../../../themes/palette.nix { inherit host lib; };
in
{
  home-manager.sharedModules = [
    (_: {
      xdg.configFile."wlogout/icons".source = ./icons;
      programs.wlogout = {
        enable = true;
        layout = [
          # {
          #   label = "lock";
          #   action = "${pkgs.hyprlock}/bin/hyprlock";
          #   text = "Lock";
          #   keybind = "l";
          # }
          # {
          #   label = "hibernate";
          #   action = "systemctl hibernate";
          #   text = "Hibernate";
          #   keybind = "h";
          # }
          {
            label = "logout";
            action = "hyprshutdown";
            # action = "killall -9 Hyprland sleep 2";
            text = "Exit";
            keybind = "e";
          }
          {
            label = "shutdown";
            action = "systemctl poweroff";
            text = "Shutdown";
            keybind = "s";
          }
          {
            label = "suspend";
            action = "systemctl suspend";
            text = "Suspend";
            keybind = "u";
          }
          {
            label = "reboot";
            action = "systemctl reboot";
            text = "Reboot";
            keybind = "r";
          }
        ];
        style = ''
          window {
            font-family: monospace;
            font-size: 14pt;
            color: ${palette.hex.text}; /* text */
            background-color: rgba(${palette.tuple.base}, 0.5);
          }

          button {
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;
            border: none;
            background-color: rgba(${palette.tuple.base}, 0);
            margin: 5px;
            transition: box-shadow 0.2s ease-in-out, background-color 0.2s ease-in-out;
          }

          button:hover {
            background-color: rgba(${palette.tuple.surface0}, 0.1);
          }

          button:focus {
            background-color: ${palette.accentHex};
            color: ${palette.hex.base};
          }
          #lock {
            background-image: image(url("icons/lock.png"));
          }
          #lock:focus {
            background-image: image(url("icons/lock-hover.png"));
          }

          #logout {
            background-image: image(url("icons/logout.png"));
          }
          #logout:focus {
            background-image: image(url("icons/logout-hover.png"));
          }

          #suspend {
            background-image: image(url("icons/sleep.png"));
          }
          #suspend:focus {
            background-image: image(url("icons/sleep-hover.png"));
          }

          #shutdown {
            background-image: image(url("icons/power.png"));
          }
          #shutdown:focus {
            background-image: image(url("icons/power-hover.png"));
          }

          #reboot {
            background-image: image(url("icons/restart.png"));
          }
          #reboot:focus {
            background-image: image(url("icons/restart-hover.png"));
          }
        '';
      };
    })
  ];
}
