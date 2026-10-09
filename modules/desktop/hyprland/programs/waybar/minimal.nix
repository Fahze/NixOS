{
  host,
  lib,
  pkgs,
  ...
}:
let
  palette = import ../../../../themes/palette.nix { inherit host lib; };
  inherit (import ../../../../../hosts/${host}/variables.nix) clock24h;
  gpuinfo = pkgs.callPackage ../../scripts/gpuinfo.nix { };
  keyboardswitch = pkgs.callPackage ../../scripts/keyboardswitch.nix { };
  waybarcava = pkgs.callPackage ../../scripts/waybarcava.nix { };
in
{
  settings = [
    {
      layer = "top";
      position = "top";
      mode = "dock";
      height = 36;
      exclusive = true;
      passthrough = false;
      gtk-layer-shell = true;
      ipc = true;
      fixed-center = true;
      margin-top = 10;
      margin-left = 10;
      margin-right = 10;
      margin-bottom = 0;

      modules-left = [
        "hyprland/workspaces"
        "cava"
      ];
      # modules-center = ["clock" "custom/notification"];
      modules-center = [
        "idle_inhibitor"
        "clock"
      ];
      modules-right = [
        "custom/gpuinfo"
        "cpu"
        "memory"
        "backlight"
        "pulseaudio"
        "network"
        "bluetooth"
        "tray"
        "battery"
      ];

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

      "custom/colour-temperature" = {
        format = "{} ";
        exec = "wl-gammarelay-rs watch {t}";
        on-scroll-up = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +100";
        on-scroll-down = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -100";
      };
      "custom/cava_mviz" = {
        exec = "${waybarcava}/bin/waybarcava";
        format = "{}";
      };
      "cava" = {
        hide_on_silence = false;
        framerate = 60;
        bars = 10;
        format-icons = [
          "▁"
          "▂"
          "▃"
          "▄"
          "▅"
          "▆"
          "▇"
          "█"
        ];
        input_delay = 1;
        # "noise_reduction" = 0.77;
        sleep_timer = 5;
        bar_delimiter = 0;
        on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
      };
      "custom/gpuinfo" = {
        exec = "${gpuinfo}/bin/gpuinfo --tired";
        return-type = "json";
        format = "{text}";
        on-click = "${gpuinfo}/bin/gpuinfo --toggle";
        interval = 5; # once every 5 seconds
        tooltip = true;
        max-length = 80;
      };
      "custom/icon" = {
        # format = " ";
        exec = "echo ' '";
        format = "{}";
      };
      "mpris" = {
        format = "{player_icon} {title} - {artist}";
        format-paused = "{status_icon} <i>{title} - {artist}</i>";
        player-icons = {
          default = "▶";
          spotify = "";
          mpv = "󰐹";
          vlc = "󰕼";
          firefox = "";
          chromium = "";
          kdeconnect = "";
          mopidy = "";
        };
        status-icons = {
          paused = "⏸";
          playing = "";
        };
        ignored-players = [
          "firefox"
          "chromium"
        ];
        max-length = 30;
      };
      "temperature" = {
        hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
        critical-threshold = 83;
        format = "{icon} {temperatureC}°C";
        format-icons = [
          ""
          ""
          ""
        ];
        interval = 10;
      };
      "hyprland/language" = {
        format = "{short}"; # can use {short} and {variant}
        on-click = "${keyboardswitch}/bin/keyboardswitch";
      };
      "hyprland/workspaces" = {
        all-outputs = true;
        active-only = false;
        on-click = "activate";
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
      };

      "hyprland/window" = {
        format = "{}";
        separate-outputs = true;
        rewrite = {
          "" = "Desktop";
          "kitty" = "Terminal";
          "zsh" = "Terminal";
          "~" = "Terminal";
        };
        max-length = 1000;
      };

      "idle_inhibitor" = {
        format = "{icon}";
        format-icons = {
          activated = "󰥔";
          deactivated = "";
        };
      };

      "clock" = {
        format = if clock24h == true then "{:%a %d %b %R}" else "{:%a %b %d %I:%M %p}";
        format-alt = if clock24h == true then "{:%a %b %d %I:%M %p}" else "{:%a %d %b %R}";
        # format = "{:%a %d %b %R}";
        # format = "{:%R 󰃭 %d·%m·%y}"; # Inverted
        # format-alt = "{:%I:%M %p}";
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          mode-mon-col = 3;
          on-scroll = 1;
          on-click-right = "mode";
          format = {
            months = "<span color='${palette.hex.rosewater}'><b>{}</b></span>";
            weekdays = "<span color='${palette.hex.yellow}'><b>{}</b></span>";
            today = "<span color='${palette.accentHex}'><b>{}</b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-click-forward = "tz_up";
          on-click-backward = "tz_down";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };

      "cpu" = {
        interval = 10;
        format = "󰍛 {usage}%";
        format-alt = "{icon0}{icon1}{icon2}{icon3}";
        format-icons = [
          "▁"
          "▂"
          "▃"
          "▄"
          "▅"
          "▆"
          "▇"
          "█"
        ];
      };

      "memory" = {
        interval = 30;
        format = "󰾆 {percentage}%";
        format-alt = "󰾅 {used}GB";
        max-length = 10;
        tooltip = true;
        tooltip-format = " {used:.1f}GB/{total:.1f}GB";
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
        on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 2%+";
        on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 2%-";
      };

      "network" = {
        # on-click = "nm-connection-editor";
        # "interface" = "wlp2*"; # (Optional) To force the use of this interface
        format-wifi = "󰤨 Wi-Fi";
        # format-wifi = " {bandwidthDownBits}  {bandwidthUpBits}";
        # format-wifi = "󰤨 {essid}";
        format-ethernet = "󱘖 Wired";
        # format-ethernet = " {bandwidthDownBits}  {bandwidthUpBits}";
        format-linked = "󰤪 Secure";
        # format-linked = "󱘖 {ifname} (No IP)";
        format-disconnected = "󰤮 Off";
        # format-disconnected = "󰤮 Disconnected";
        format-alt = "󰤨 {signalStrength}%";
        tooltip-format = "󱘖 {ipaddr}  {bandwidthUpBytes}  {bandwidthDownBytes}";
      };

      "bluetooth" = {
        format = "";
        # format-disabled = ""; # an empty format will hide the module
        format-connected = " {num_connections}";
        tooltip-format = " {device_alias}";
        tooltip-format-connected = "{device_enumerate}";
        tooltip-format-enumerate-connected = " {device_alias}";
        on-click = "blueman-manager";
      };

      "pulseaudio" = {
        format = "{icon} {volume}";
        format-muted = " ";
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol -t 3";
        tooltip-format = "{icon} {desc} // {volume}%";
        scroll-step = 4;
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [
            ""
            ""
            ""
          ];
        };
      };

      "pulseaudio#microphone" = {
        format = "{format_source}";
        format-source = " {volume}%";
        format-source-muted = "";
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol -t 4";
        tooltip-format = "{format_source} {source_desc} // {source_volume}%";
        scroll-step = 5;
      };

      "tray" = {
        icon-size = 14; # 12
        spacing = 6; # 5
      };

      "battery" = {
        states = {
          good = 95;
          warning = 30;
          critical = 20;
        };
        format = "{icon} {capacity}%";
        # format-charging = " {capacity}%";
        format-charging = " {capacity}%";
        format-plugged = " {capacity}%";
        format-alt = "{time} {icon}";
        format-icons = [
          "󰂎"
          "󰁺"
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
      };

      "custom/power" = {
        format = "{}";
        on-click = "wlogout -b 5";
        interval = 86400; # once every day
        tooltip = true;
      };
    }
  ];
  style = ''
    * {
      font-family: "monospace";
      font-size: 15px;
      margin: 0px;
      padding: 0px;
    }

    @define-color base   ${palette.hex.base};
    @define-color mantle ${palette.hex.mantle};
    @define-color crust  ${palette.hex.crust};

    @define-color text     ${palette.hex.text};
    @define-color subtext0 ${palette.hex.subtext0};
    @define-color subtext1 ${palette.hex.subtext1};

    @define-color surface0 ${palette.hex.surface0};
    @define-color surface1 ${palette.hex.surface1};
    @define-color surface2 ${palette.hex.surface2};

    @define-color overlay0 ${palette.hex.overlay0};
    @define-color overlay1 ${palette.hex.overlay1};
    @define-color overlay2 ${palette.hex.overlay2};

    @define-color blue      ${palette.hex.blue};
    @define-color lavender  ${palette.hex.lavender};
    @define-color sapphire  ${palette.hex.sapphire};
    @define-color sky       ${palette.hex.sky};
    @define-color teal      ${palette.hex.teal};
    @define-color green     ${palette.hex.green};
    @define-color yellow    ${palette.hex.yellow};
    @define-color peach     ${palette.hex.peach};
    @define-color maroon    ${palette.hex.maroon};
    @define-color red       ${palette.hex.red};
    @define-color mauve     ${palette.hex.mauve};
    @define-color pink      ${palette.hex.pink};
    @define-color flamingo  ${palette.hex.flamingo};
    @define-color rosewater ${palette.hex.rosewater};

    @define-color accent ${palette.accentHex};

    window#waybar {
      transition-property: background-color;
      transition-duration: 0.5s;
      background: transparent;
      border-radius: 11px;
    }

    window#waybar.hidden {
      opacity: 0.2;
    }

    tooltip {
      background: alpha(@base, 0.85);
      border-radius: 9px;
    }

    tooltip label {
      color: ${palette.hex.text};
      margin-right: 6px;
      margin-left: 6px;
    }

    /* This section can be use if you want to separate waybar modules */
    .modules-left {
      background: alpha(@base, 0.85);
      border: 1px solid @accent;
      padding-right: 16px;
      padding-left: 3px;
      border-radius: 11px;
    }
    .modules-center {
      background: alpha(@base, 0.85);
      border: 1px solid @overlay0;
      padding-right: 6px;
      padding-left: 6px;
      border-radius: 11px;
    }
    .modules-right {
      background: alpha(@base, 0.85);
      border: 1px solid @accent;
      padding-right: 16px;
      padding-left: 16px;
      border-radius: 11px;
    }

    #backlight,
    #backlight-slider,
    #battery,
    #bluetooth,
    #clock,
    #cpu,
    #disk,
    #idle_inhibitor,
    #keyboard-state,
    #memory,
    #mode,
    #mpris,
    #network,
    #pulseaudio,
    #pulseaudio-slider,
    #taskbar button,
    #taskbar,
    #temperature,
    #tray,
    #window,
    #wireplumber,
    #workspaces,
    #custom-backlight,
    #custom-cycle_wall,
    #custom-gpuinfo,
    #custom-keybinds,
    #custom-keyboard,
    #custom-light_dark,
    #custom-lock,
    #custom-menu,
    #custom-power_vertical,
    #custom-power,
    #custom-swaync,
    #custom-updater,
    #custom-weather,
    #custom-weather.clearNight,
    #custom-weather.cloudyFoggyDay,
    #custom-weather.cloudyFoggyNight,
    #custom-weather.default,
    #custom-weather.rainyDay,
    #custom-weather.rainyNight,
    #custom-weather.severe,
    #custom-weather.showyIcyDay,
    #custom-weather.snowyIcyNight,
    #custom-weather.sunnyDay {
      padding-top: 3px;
      padding-bottom: 3px;
      padding-right: 6px;
      padding-left: 6px;
    }

    #idle_inhibitor {
      color: @blue;
    }

    #bluetooth,
    #backlight {
      color: @blue;
    }

    #battery {
      color: @green;
    }

    @keyframes blink {
      to {
        color: @surface0;
      }
    }

    #battery.critical:not(.charging) {
      background-color: @red;
      color: @theme_text_color;
      animation-name: blink;
      animation-duration: 0.5s;
      animation-timing-function: linear;
      animation-iteration-count: infinite;
      animation-direction: alternate;
      box-shadow: inset 0 -3px transparent;
    }

    #custom-updates {
      color: @blue
    }
    #custom-notification {
      color: #dfdfdf;
      padding: 0px 6px;
      border-radius: 5px;
    }

    #language {
      color: @blue
    }
    #clock {
      color: @yellow;
    }

    #custom-icon {
      font-size: 16px;
      color: ${palette.accentHex};
    }

    #custom-gpuinfo {
      color: @maroon;
    }

    #cpu {
      color: @yellow;
    }

    #custom-keyboard,
    #memory {
      color: @green;
    }

    #disk {
      color: @sapphire;
    }

    #temperature {
      color: @teal;
    }

    #temperature.critical {
      background-color: @red;
    }

    #tray > .passive {
      -gtk-icon-effect: dim;
    }
    #tray > .needs-attention {
      -gtk-icon-effect: highlight;
    }

    #keyboard-state {
      color: @flamingo;
    }

    #workspaces button {
      box-shadow: none;
      text-shadow: none;
      padding: 0px;
      border-radius: 10px;
      padding-left: 5px;
      padding-right: 5px;
      animation: gradient_f 20s ease-in infinite;
      transition: all 0.5s cubic-bezier(.55,-0.68,.48,1.682);
    }

    #workspaces button:hover {
      border-radius: 11px;
      color: @overlay0;
      background-color: @surface0;
      padding-left: 3px;
      padding-right: 3px;
      animation: gradient_f 20s ease-in infinite;
      transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
    }

    #workspaces button.persistent {
      color: @surface1;
      border-radius: 11px;
    }

    #workspaces button.active {
      color: @accent;
      border-radius: 11px;
      padding-left: 9px;
      padding-right: 9px;
      animation: gradient_f 20s ease-in infinite;
      transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
    }

    #workspaces button.urgent {
      color: @red;
      border-radius: 0px;
    }

    #taskbar button.active {
      padding-left: 9px;
      padding-right: 9px;
      animation: gradient_f 20s ease-in infinite;
      transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
    }

    #taskbar button:hover {
      padding-left: 3px;
      padding-right: 3px;
      animation: gradient_f 20s ease-in infinite;
      transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
    }

    #custom-cava_mviz {
      color: @pink;
    }

    #cava {
      color: @pink;
    }

    #mpris {
      color: @pink;
    }

    #custom-menu {
      color: @rosewater;
    }

    #custom-power {
      color: @red;
    }

    #custom-updater {
      color: @red;
    }

    #custom-light_dark {
      color: @blue;
    }

    #custom-weather {
      color: @lavender;
    }

    #custom-lock {
      color: @maroon;
    }

    #pulseaudio {
      color: @lavender;
    }

    #pulseaudio.bluetooth {
      color: @pink;
    }
    #pulseaudio.muted {
      color: @red;
    }

    #window {
      color: @mauve;
    }

    #custom-waybar-mpris {
      color:@lavender;
    }

    #network {
      color: @blue;
    }
    #network.disconnected,
    #network.disabled {
      background-color: @surface0;
      color: @text;
    }

    #pulseaudio-slider slider {
      min-width: 0px;
      min-height: 0px;
      opacity: 0;
      background-image: none;
      border: none;
      box-shadow: none;
    }

    #pulseaudio-slider trough {
      min-width: 90px;
      min-height: 6px;
      border-radius: 6px;
    }

    #pulseaudio-slider highlight {
      min-height: 11px;
      border-radius: 6px;
    }

    #backlight-slider slider {
      min-width: 0px;
      min-height: 0px;
      opacity: 0;
      background-image: none;
      border: none;
      box-shadow: none;
    }

    #backlight-slider trough {
      min-width: 90px;
      min-height: 11px;
      border-radius: 6px;
    }

    #backlight-slider highlight {
      min-width: 11px;
      border-radius: 6px;
    }
  '';
}
