{
  flake.modules.homeManager.waybar =
    {
      programs.waybar = {
        enable = true;
        systemd.enable = true;

        settings = [
          {
            layer = "top";
            position = "top";
            height = 38;
            spacing = 0;
            exclusive = true;

            modules-left = [ "hyprland/workspaces" ];
            modules-center = [ "clock" ];
            modules-right = [ "tray" "network" "bluetooth" "pulseaudio" "battery" ];

            "hyprland/workspaces" = {
              format = "";
              on-click = "activate";
              persistent-workspaces = {
                "*" = 5;
              };
            };

            clock = {
              format = "{:%I:%M %p}";
              format-alt = "{:%A, %B %d}";
              tooltip-format = "<tt><small>{calendar}</small></tt>";
            };

            network = {
              format-wifi = "󰤨";
              format-ethernet = "󰛳";
              format-disconnected = "󰤮";
              format-linked = "󰤮";
              tooltip-format-wifi = "{essid} ({signalStrength}%)";
              tooltip-format-ethernet = "{ifname}: {ipaddr}";
              tooltip-format-disconnected = "Disconnected";
            };

            bluetooth = {
              format = "󰂯";
              format-disabled = "";
              format-off = "";
              tooltip-format = "{controller_alias} ({controller_address})";
            };

            pulseaudio = {
              format = "{icon}";
              format-muted = "󰝟";
              format-icons = {
                default = [ "󰕿" "󰖀" "󰕾" ];
              };
              on-click = "pavucontrol";
              scroll-step = 5;
            };

            battery = {
              format = "{icon}";
              format-charging = "󰂄";
              format-plugged = "󰁹";
              format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
              states = {
                warning = 30;
                critical = 15;
              };
            };

            tray = {
              icon-size = 15;
              spacing = 6;
            };
          }
        ];

        style = ''
          /* Catppuccin Mocha */
          * {
            font-family: "Maple Mono NF", "JetBrainsMono Nerd Font Propo", monospace;
            font-size: 14px;
            min-height: 0;
            border: none;
            border-radius: 0;
            padding: 0;
            margin: 0;
          }

          window#waybar {
            background-color: rgba(24, 24, 37, 0.92);
            border-bottom: 1px solid rgba(49, 50, 68, 0.6);
            color: #cdd6f4;
          }

          /* ── Workspaces ────────────────────────────────────── */
          #workspaces {
            padding: 0 10px;
          }

          #workspaces button {
            all: unset;
            min-width: 14px;
            min-height: 14px;
            border-radius: 7px;
            background-color: #585b70;
            margin: 12px 3px;
            opacity: 0.35;
            transition: all 180ms ease;
          }

          #workspaces button.occupied {
            opacity: 0.9;
          }

          #workspaces button.active {
            min-width: 32px;
            background-color: #89b4fa;
            opacity: 1;
          }

          #workspaces button.urgent {
            background-color: #f38ba8;
            opacity: 1;
          }

          #workspaces button:hover {
            background-color: #cdd6f4;
            min-width: 22px;
            opacity: 1;
          }

          /* ── Clock ─────────────────────────────────────────── */
          #clock {
            color: #cdd6f4;
            font-weight: bold;
            padding: 0 8px;
          }

          /* ── Right modules ─────────────────────────────────── */
          #tray,
          #network,
          #bluetooth,
          #pulseaudio,
          #battery {
            padding: 0 6px;
            color: #cdd6f4;
          }

          #network.disconnected,
          #network.linked {
            color: #6c7086;
          }

          #pulseaudio.muted {
            color: #6c7086;
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
