{
  flake.modules.homeManager.waybar =
    {
      programs.waybar = {
        enable = true;
        systemd.enable = true;

        settings = [
          {
            reload_style_on_change = true;
            layer = "top";
            position = "top";
            spacing = 0;
            height = 26;

            modules-left = [ "hyprland/workspaces" ];
            modules-center = [ "clock" "cpu" ];
            modules-right = [
              "tray"
              "bluetooth"
              "network"
              "pulseaudio"
              "battery"
            ];

            "hyprland/workspaces" = {
              on-click = "activate";
              format = "{icon}";
              format-icons = {
                default = "";
                "1" = "1";
                "2" = "2";
                "3" = "3";
                "4" = "4";
                "5" = "5";
                "6" = "6";
                "7" = "7";
                "8" = "8";
                "9" = "9";
                "10" = "0";
                active = "󱓻";
              };
              persistent-workspaces = {
                "1" = [ ];
                "2" = [ ];
                "3" = [ ];
                "4" = [ ];
                "5" = [ ];
              };
            };

            cpu = {
              interval = 5;
              format = "󰍛";
              on-click = "kitty btop";
            };

            clock = {
              format = "{:L%A %H:%M}";
              format-alt = "{:L%d %B W%V %Y}";
              tooltip = false;
            };

            network = {
              format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
              format = "{icon}";
              format-wifi = "{icon}";
              format-ethernet = "󰀂";
              format-disconnected = "󰤮";
              tooltip-format-wifi = "{essid} ({frequency} GHz)";
              tooltip-format-ethernet = "Connected";
              tooltip-format-disconnected = "Disconnected";
              interval = 3;
              spacing = 1;
              on-click = "nm-connection-editor";
            };

            battery = {
              format = "{capacity}% {icon}";
              format-discharging = "{icon}";
              format-charging = "{icon}";
              format-plugged = "";
              format-full = "󰂅";
              format-icons = {
                charging = [ "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅" ];
                default = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
              };
              tooltip-format-discharging = "{power:>1.0f}W↓ {capacity}%";
              tooltip-format-charging = "{power:>1.0f}W↑ {capacity}%";
              interval = 5;
              states = {
                warning = 20;
                critical = 10;
              };
            };

            bluetooth = {
              format = "";
              format-off = "󰂲";
              format-disabled = "󰂲";
              format-connected = "󰂱";
              format-no-controller = "";
              tooltip-format = "Devices connected: {num_connections}";
              on-click = "blueman-manager";
            };

            pulseaudio = {
              format = "{icon}";
              on-click = "pavucontrol";
              on-click-right = "pamixer -t";
              tooltip-format = "Playing at {volume}%";
              scroll-step = 5;
              format-muted = "";
              format-icons = {
                headphone = "";
                headset = "";
                default = [ "" "" "" ];
              };
            };

            tray = {
              icon-size = 12;
              spacing = 17;
            };
          }
        ];

        style = ''
          /* Catppuccin Mocha */

          * {
            background-color: #1e1e2e;
            color: #cdd6f4;
            border: none;
            border-radius: 0;
            min-height: 0;
            font-family: 'Maple Mono NF';
            font-size: 12px;
          }

          .modules-left {
            margin-left: 8px;
          }

          .modules-right {
            margin-right: 8px;
          }

          #workspaces button {
            all: initial;
            padding: 0 6px;
            margin: 0 1.5px;
            min-width: 9px;
            color: #cdd6f4;
            font-family: 'Maple Mono NF';
            font-size: 12px;
          }

          #workspaces button.empty {
            opacity: 0.5;
          }

          #workspaces button.active {
            color: #89b4fa;
          }

          #workspaces button.urgent {
            color: #f38ba8;
          }

          #cpu,
          #battery,
          #pulseaudio {
            min-width: 12px;
            margin: 0 7.5px;
          }

          #tray {
            margin-right: 16px;
          }

          #bluetooth {
            margin-right: 17px;
          }

          #network {
            margin-right: 13px;
          }

          tooltip {
            padding: 2px;
          }

          #clock {
            margin-left: 8.75px;
            margin-right: 8.75px;
          }

          .hidden {
            opacity: 0;
          }

          #battery.charging {
            color: #a6e3a1;
          }

          #battery.warning {
            color: #fab387;
          }

          #battery.critical {
            color: #f38ba8;
          }

          #pulseaudio.muted {
            color: #45475a;
          }

          #network.disconnected {
            color: #45475a;
          }

          #tray > .passive {
            -gtk-icon-effect: dim;
          }

          #tray > .needs-attention {
            -gtk-icon-effect: highlight;
          }
        '';
      };
    };
}
