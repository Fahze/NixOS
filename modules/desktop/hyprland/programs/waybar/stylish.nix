{
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ../../../../../hosts/${host}/variables.nix) clock24h terminal;
  palette = import ../../../../themes/palette.nix { inherit host lib; };
  gpuinfo = pkgs.callPackage ../../scripts/gpuinfo.nix { };
in
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        # Colors only: regenerated from palette.nix on every build. Kept
        # separate from stylish.css (an out-of-store symlink below) so
        # that file can be hand-edited live without needing a rebuild.
        xdg.configFile."waybar/palette.css".text = ''
          @define-color rosewater		${palette.hex.rosewater};
          @define-color flamingo		${palette.hex.flamingo};
          @define-color pink			${palette.hex.pink};
          @define-color mauve			${palette.hex.mauve};
          @define-color red			${palette.hex.red};
          @define-color maroon		${palette.hex.maroon};
          @define-color peach			${palette.hex.peach};
          @define-color yellow		${palette.hex.yellow};
          @define-color green			${palette.hex.green};
          @define-color teal			${palette.hex.teal};
          @define-color sky			${palette.hex.sky};
          @define-color sapphire		${palette.hex.sapphire};
          @define-color blue			${palette.hex.blue};
          @define-color lavender		${palette.hex.lavender};
          @define-color text			${palette.hex.text};
          @define-color subtext1		${palette.hex.subtext1};
          @define-color subtext0		${palette.hex.subtext0};
          @define-color overlay2		${palette.hex.overlay2};
          @define-color overlay1		${palette.hex.overlay1};
          @define-color overlay0		${palette.hex.overlay0};
          @define-color surface2		${palette.hex.surface2};
          @define-color surface1		${palette.hex.surface1};
          @define-color surface0		${palette.hex.surface0};
          @define-color base			${palette.hex.base};
          @define-color mantle		${palette.hex.mantle};
          @define-color crust			${palette.hex.crust};

          @define-color accent		${palette.accentHex};
          @define-color main-br		@subtext0;
          @define-color main-bg		@crust;
          @define-color main-fg		@text;
          @define-color hover-bg		@base;
          @define-color hover-fg		alpha(@main-fg, 0.75);
          @define-color outline		shade(@main-bg, 0.5);

          @define-color workspaces	@mantle;
          @define-color temperature	@mantle;
          @define-color memory		@base;
          @define-color cpu			@surface0;
          @define-color time			@surface0;
          @define-color date			@base;
          @define-color tray			@mantle;
          @define-color volume		@mantle;
          @define-color backlight		@base;
          @define-color battery		@surface0;

          @define-color warning		@yellow;
          @define-color critical		@red;
          @define-color charging		@green;
        '';

        programs.waybar = {
          enable = true;
          settings = [
            {
              layer = "top";
              position = "top";
              mode = "dock";
              height = 0;
              spacing = 0;
              exclusive = true;
              passthrough = false;
              gtk-layer-shell = true;
              reload_style_on_change = true;
              ipc = true;
              fixed-center = true;
              margin-top = 0;
              margin-left = 0;
              margin-right = 0;
              margin-bottom = 0;

              modules-left = [
                "group/user"
                "custom/left_div-1"
                "hyprland/workspaces"
                "custom/right_div-1"
                "hyprland/window"
              ];
              modules-center = [
                "hyprland/windowcount"
                "custom/left_div-2"
                "custom/gpuinfo"
                "custom/left_div-3"
                "memory"
                "custom/left_div-4"
                "cpu"
                "custom/left_inv-1"
                "custom/left_div-5"
                "custom/distro"
                "custom/right_div-2"
                "custom/right_inv-1"
                "idle_inhibitor"
                "clock#time"
                "custom/right_div-3"
                "clock#date"
                "custom/right_div-4"
                "network"
                "bluetooth"
                "custom/system_update"
                "custom/right_div-5"
              ];
              modules-right = [
                "mpris"
                "custom/left_div-6"
                "group/pulseaudio"
                "custom/left_div-7"
                "backlight"
                "custom/left_div-8"
                "battery"
                "custom/left_inv-2"
                "custom/notification"
                "custom/power_menu"
              ];

              "group/user" = {
                orientation = "horizontal";
                modules = [
                  "custom/trigger"
                  # "custom/user"
                  "tray"
                  # "wlr/taskbar"
                ];
                drawer = { };
              };
              "custom/trigger" = {
                format = "󰍜";
                min-length = 4;
                max-length = 4;
                tooltip = false;
              };
              "custom/user" = {
                exec = "id -un";
                format = "{}";
                tooltip = false;
              };
              "wlr/taskbar" = {
                on-click = "activate";
                ignore-list = [ "kitty" ];
                cursor = true;
              };

              "hyprland/workspaces" = {
                format = "{icon}";
                format-icons = {
                  active = "";
                  default = "";
                };
                persistent-workspaces = {
                  "*" = [
                    1
                    2
                    3
                    4
                    5
                    6
                    7
                    8
                    9
                    10
                  ];
                };
                on-scroll-up = "hyprctl dispatch workspace +1";
                on-scroll-down = "hyprctl dispatch workspace -1";
                cursor = true;
              };

              "hyprland/window" = {
                format = "{}";
                rewrite = {
                  "" = "Desktop";
                  "kitty" = "Terminal";
                  "zsh" = "Terminal";
                  "~" = "Terminal";
                };
                swap-icon-label = false;
                icon = true;
              };

              "hyprland/windowcount" = {
                format = "[{}]";
                swap-icon-label = false;
              };

              "temperature" = {
                hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
                critical-threshold = 90;
                format-critical = "󰀦 {temperatureC}°C";
                format = "{icon} {temperatureC}°C";
                format-icons = [
                  "󱃃"
                  "󰔏"
                  "󱃂"
                ];
                interval = 10;
              };
              "memory" = {
                interval = 10;
                format = "󰘚 {percentage}%";
                format-warning = "󰀧 {percentage}%";
                format-critical = "󰀧 {percentage}%";
                states = {
                  warning = 75;
                  critical = 90;
                };
                min-length = 7;
                max-length = 7;
                tooltip-format = "Memory Used: {used:0.1f} GB / {total:0.1f} GB";
              };
              "cpu" = {
                interval = 10;
                format = "󰍛 {usage}%";
                format-warning = "󰀨 {usage}%";
                format-critical = "󰀨 {usage}%";
                min-length = 7;
                max-length = 7;
                states = {
                  warning = 75;
                  critical = 90;
                };
                tooltip = false;
              };

              "custom/distro" = {
                format = "";
                tooltip = true;
                tooltip-format = "I use NixOS, btw.";
              };

              "idle_inhibitor" = {
                format = "{icon}";
                format-icons = {
                  activated = "󰈈";
                  deactivated = "󰈉";
                };
                min-length = 3;
                max-length = 3;
                tooltip-format-activated = "Keep Screen On: <span text_transform='capitalize'>{status}</span>";
                tooltip-format-deactivated = "Keep Screen On: <span text_transform='capitalize'>{status}</span>";
                start-activated = false;
              };

              "clock#time" = {
                format = if clock24h == true then "{:%R}" else "{:%I:%M}";
                format-alt = if clock24h == true then "{:%I:%M}" else "{:%R}";
                min-length = 5;
                max-length = 5;
                tooltip-format = "Standard Time: {:%I:%M %p}";
              };
              "clock#date" = {
                format = "󰸗 {:%m-%d}";
                min-length = 7;
                max-length = 7;
                tooltip-format = "{calendar}";
                calendar = {
                  mode = "month";
                  mode-mon-col = 6;
                  format = {
                    months = "<span alpha='100%'><b>{}</b></span>";
                    days = "<span alpha='90%'>{}</span>";
                    weekdays = "<span alpha='80%'><i>{}</i></span>";
                    today = "<span alpha='100%'><b><u>{}</u></b></span>";
                  };
                };
                actions = {
                  on-click = "mode";
                };
              };

              "network" = {
                interval = 10;
                format = "󰤨";
                format-ethernet = "󰈀";
                format-wifi = "{icon}";
                format-disconnected = "󰤯";
                format-disabled = "󰤮";
                format-icons = [
                  "󰤟"
                  "󰤢"
                  "󰤥"
                  "󰤨"
                ];
                min-length = 2;
                max-length = 2;
                on-click = "nm-connection-editor";
                tooltip-format = "Gateway: {gwaddr}";
                tooltip-format-ethernet = "Interface: {ifname}";
                tooltip-format-wifi = "Network: {essid}\nIP Addr: {ipaddr}/{cidr}\nStrength: {signalStrength}%\nFrequency: {frequency} GHz";
                tooltip-format-disconnected = "Wi-Fi Disconnected";
                tooltip-format-disabled = "Wi-Fi Disabled";
              };
              "bluetooth" = {
                format = "󰂯";
                format-disabled = "󰂲";
                format-off = "󰂲";
                format-on = "󰂰";
                format-connected = "󰂱";
                min-length = 2;
                max-length = 2;
                on-click = "blueman-manager";
                on-click-right = "bluetoothctl power off && notify-send 'Bluetooth Off' -i 'network-bluetooth-inactive' -r 1925";
                tooltip-format = "Device Addr: {device_address}";
                tooltip-format-disabled = "Bluetooth Disabled";
                tooltip-format-off = "Bluetooth Off";
                tooltip-format-on = "Bluetooth Disconnected";
                tooltip-format-connected = "Device: {device_alias}";
                tooltip-format-enumerate-connected = "Device: {device_alias}";
                tooltip-format-connected-battery = "Device: {device_alias}\nBattery: {device_battery_percentage}%";
                tooltip-format-enumerate-connected-battery = "Device: {device_alias}\nBattery: {device_battery_percentage}%";
              };

              "custom/system_update" = {
                format = "";
                on-click = "${terminal} -e rebuild";
                min-length = 1;
                max-length = 1;
                tooltip = false;
              };

              "mpris" = {
                format = "{player_icon} {title} - {artist}";
                format-paused = "{status_icon} {title} - {artist}";
                tooltip-format = "Playing: {title} - {artist}";
                tooltip-format-paused = "Paused: {title} - {artist}";
                player-icons = {
                  default = "󰐊";
                };
                status-icons = {
                  paused = "󰏤";
                };
                max-length = 1000;
              };

              "group/pulseaudio" = {
                orientation = "horizontal";
                modules = [
                  "pulseaudio#output"
                  "pulseaudio#input"
                  # "tray"
                ];
                drawer = {
                  # "transition-duration":
                  transition-left-to-right = false;
                  # "children-class":
                  # "click-to-reveal":
                };
              };

              "pulseaudio#output" = {
                format = "{icon} {volume}%";
                # "format-bluetooth":
                format-muted = "{icon} {volume}%";
                # "format-source":
                # "format-source-muted":
                format-icons = {
                  default = [
                    "󰕿"
                    "󰖀"
                    "󰕾"
                  ];
                  default-muted = "󰝟";
                  headphone = "󰋋";
                  headphone-muted = "󰟎";
                  headset = "󰋎";
                  headset-muted = "󰋐";
                };
                min-length = 7;
                max-length = 7;
                on-click = "${pkgs.pavucontrol}/bin/pavucontrol -t 3";
                tooltip-format = "Output Device: {desc}";
              };

              "pulseaudio#input" = {
                format = "{format_source}";
                format-source = "󰍬 {volume}%";
                format-source-muted = "󰍭 {volume}%";
                min-length = 7;
                max-length = 7;
                scroll-step = 1;
                on-click = "${pkgs.pavucontrol}/bin/pavucontrol -t 4";
                # on-click = "${pkgs.pamixer}/bin/pamixer --default-source --toggle-mute";
                tooltip-format = "Input Device: {desc}";
              };

              "group/wireplumber" = {
                orientation = "horizontal";
                modules = [
                  "wireplumber#output"
                  "wireplumber#input"
                  "tray"
                ];
                drawer = {
                  transition-left-to-right = false;
                };
              };
              "wireplumber#output" = {
                format = "{icon} {volume}%";
                format-muted = "{icon} {volume}%";
                format-icons = {
                  default = [
                    "󰕿"
                    "󰖀"
                    "󰕾"
                  ];
                  default-muted = "󰝟";
                  headphone = "󰋋";
                  headphone-muted = "󰟎";
                  headset = "󰋎";
                  headset-muted = "󰋐";
                };
                on-click = "${pkgs.pavucontrol}/bin/pavucontrol -t 3";
                on-scroll-up = "wpctl set-volume @DEFAULT_SINK@ 1%+";
                on-scroll-down = "wpctl set-volume @DEFAULT_SINK@ 1%-";
                tooltip-format = "{icon} {node_name} // {volume}%";
                min-length = 7;
                max-length = 7;
                scroll-step = 1;
                node-type = "Audio/Sink";
              };
              "wireplumber#input" = {
                format = "{icon} {volume}%";
                format-muted = "";
                format-icons = {
                  default = "";
                };
                min-length = 7;
                max-length = 7;
                scroll-step = 1;
                on-click = "${pkgs.pamixer}/bin/pamixer --default-source --toggle-mute";
                node-type = "Audio/Source";
              };
              "tray" = {
                icon-size = 16;
                spacing = 12;
                cursor = true;
              };

              "backlight" = {
                format = "{icon} {percent}%";
                format-icons = [
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                ];
                min-length = 7;
                max-length = 7;
                on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 1%+";
                on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 1%-";
                tooltip = false;
              };

              "battery" = {
                states = {
                  warning = 20;
                  critical = 10;
                };
                format = "{icon} {capacity}%";
                format-time = "{H} hr {M} min";
                format-icons = [
                  "󰂎"
                  "󰁻"
                  "󰁼"
                  "󰁽"
                  "󰁾"
                  "󰁿"
                  "󰂀"
                  "󰂁"
                  "󰂂"
                  "󰁹"
                ];
                format-charging = "󰉁 {capacity}%";
                min-length = 7;
                max-length = 7;
                tooltip-format = "Discharging: {time}";
                tooltip-format-charging = "Charging: {time}";
              };

              "custom/notification" = {
                tooltip = false;
                format = "{icon}";
                format-icons = {
                  notification = "<span foreground='red'><sup></sup></span>";
                  none = "";
                  dnd-notification = "<span foreground='red'><sup></sup></span>";
                  dnd-none = "";
                  inhibited-notification = "<span foreground='red'><sup></sup></span>";
                  inhibited-none = "";
                  dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
                  dnd-inhibited-none = "";
                };
                return-type = "json";
                exec-if = "which swaync-client";
                exec = "swaync-client -swb";
                on-click = "swaync-client -t -sw";
                on-click-right = "swaync-client -d -sw";
                escape = true;
              };

              "custom/power_menu" = {
                format = "";
                on-click = "pkill -x wlogout || wlogout -b 5";
                tooltip-format = "Power Menu";
              };

              "custom/left_div-1" = {
                format = "";
                tooltip = false;
              };
              "custom/left_div-2" = {
                format = "";
                tooltip = false;
              };
              "custom/left_div-3" = {
                format = "";
                tooltip = false;
              };
              "custom/left_div-4" = {
                format = "";
                tooltip = false;
              };
              "custom/left_div-5" = {
                format = "";
                tooltip = false;
              };
              "custom/left_div-6" = {
                format = "";
                tooltip = false;
              };
              "custom/left_div-7" = {
                format = "";
                tooltip = false;
              };
              "custom/left_div-8" = {
                format = "";
                tooltip = false;
              };
              "custom/left_inv-1" = {
                format = "";
                tooltip = false;
              };
              "custom/left_inv-2" = {
                format = "";
                tooltip = false;
              };
              "custom/right_div-1" = {
                format = "";
                tooltip = false;
              };
              "custom/right_div-2" = {
                format = "";
                tooltip = false;
              };
              "custom/right_div-3" = {
                format = "";
                tooltip = false;
              };
              "custom/right_div-4" = {
                format = "";
                tooltip = false;
              };
              "custom/right_div-5" = {
                format = "";
                tooltip = false;
              };
              "custom/right_inv-1" = {
                format = "";
                tooltip = false;
              };

              "custom/gpuinfo" = {
                min-length = 7;
                max-length = 7;
                exec = "${gpuinfo}/bin/gpuinfo";
                return-type = "json";
                format = "{0}";
                on-click = "${gpuinfo}/bin/gpuinfo --toggle";
                interval = 10;
                tooltip = true;
              };
            }
          ];
          # A literal path to the live repo on disk, not `${self}` (which a
          # flake always copies into an immutable store path first --
          # editing that copy would need a rebuild to be picked up, which
          # defeats the point of an out-of-store symlink).
          style = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/NixOS/modules/desktop/hyprland/programs/waybar/stylish.css";
        };
      }
    )
  ];
}
