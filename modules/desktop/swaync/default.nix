{
  flake.modules.homeManager.swaync =
    { pkgs, ... }:

    {
      services.swaync = {
        enable = true;

        settings = {
          positionX = "right";
          positionY = "top";
          layer = "overlay";
          control-center-layer = "overlay";
          layer-shell = true;
          cssPriority = "user";
          control-center-margin-top = 8;
          control-center-margin-bottom = 0;
          control-center-margin-right = 8;
          control-center-margin-left = 0;
          notification-2fa-action = true;
          notification-inline-replies = false;
          notification-icon-size = 48;
          notification-body-image-height = 100;
          notification-body-image-width = 200;
          timeout = 5;
          timeout-low = 3;
          timeout-critical = 0;
          fit-to-screen = false;
          control-center-width = 380;
          control-center-height = 600;
          notification-window-width = 380;
          keyboard-shortcuts = true;
          image-visibility = "when-available";
          transition-time = 200;
          hide-on-clear = true;
          hide-on-action = true;
          script-fail-notify = true;
          widgets = [
            "notifications"
            "mpris"
            "volume"
            "backlight"
            "dnd"
          ];
          widget-config = {
            volume = { label = "󰕾"; };
            backlight = { label = "󰃟"; };
            mpris = {
              image-size = 96;
              image-radius = 12;
            };
          };
        };

        style = ''
          @import "/home/aman/.config/swaync/colors.css";

          * {
            color: @fg;
            all: unset;
            font-size: 14px;
            font-family: "Maple Mono NF", "Symbols Nerd Font Mono";
            transition: 200ms;
          }

          .notification-row {
            outline: none;
            margin: 0;
            padding: 0px;
          }

          .floating-notifications.background .notification-row .notification-background {
            background: alpha(@bg, .55);
            box-shadow: 0 0 8px 0 rgba(0,0,0,.6);
            border: 1px solid @accent;
            border-radius: 16px;
            margin: 16px;
            padding: 0;
          }

          .floating-notifications.background .notification-row .notification-background .notification {
            padding: 6px;
            border-radius: 12px;
          }

          .floating-notifications.background .notification-row .notification-background .notification.critical {
            border: 2px solid @danger;
          }

          .floating-notifications.background .notification-row .notification-background .notification .notification-content {
            margin: 14px;
          }

          .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
            min-height: 3.4em;
          }

          .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
            border-radius: 8px;
            background-color: alpha(@elevated, 0.4);
            margin: 6px;
            border: 1px solid transparent;
          }

          .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
            background-color: alpha(@accent, 0.18);
            border: 1px solid @accent;
          }

          .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
            background-color: @accent;
            color: @bg;
          }

          .image {
            margin: 10px 20px 10px 0px;
          }

          .summary {
            font-weight: 800;
            font-size: 1rem;
          }

          .body {
            font-size: 0.8rem;
          }

          .floating-notifications.background .notification-row .notification-background .close-button {
            margin: 6px;
            padding: 2px;
            border-radius: 8px;
            background-color: transparent;
            border: 1px solid transparent;
          }

          .floating-notifications.background .notification-row .notification-background .close-button:hover {
            background-color: alpha(@danger, 0.2);
          }

          .floating-notifications.background .notification-row .notification-background .close-button:active {
            background-color: @danger;
            color: @bg;
          }

          .notification.critical progress {
            background-color: @danger;
          }

          .notification.low progress,
          .notification.normal progress {
            background-color: @accent;
          }

          notificationwindow,
          blankwindow {
            background: transparent;
          }

          /* gtk-4.0/gtk.css (libadwaita theme) paints .background at user
             priority; override it so the layer surface stays transparent */
          window.background {
            background: transparent;
          }

          .control-center {
            background: alpha(@bg, .55);
            border-radius: 16px;
            border: 1px solid @accent;
            box-shadow: 0 0 10px 0 rgba(0,0,0,.6);
            margin: 18px;
            padding: 12px;
          }

          .control-center .notification-row .notification-background,
          .control-center .notification-row .notification-background .notification.critical {
            background-color: alpha(@elevated, .4);
            border-radius: 12px;
            margin: 4px 0px;
            padding: 4px;
          }

          .control-center .notification-row .notification-background .notification.critical {
            color: @danger;
          }

          .control-center .notification-row .notification-background .notification .notification-content {
            margin: 6px;
            padding: 8px 6px 2px 2px;
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * {
            min-height: 3.4em;
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
            background: alpha(@accent, .6);
            color: @fg;
            border-radius: 12px;
            margin: 6px;
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
            background: @accent;
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
            background-color: @accent;
          }

          .control-center .notification-row .notification-background .close-button {
            background: transparent;
            border-radius: 8px;
            color: @fg;
            margin: 0px;
            padding: 4px;
          }

          .control-center .notification-row .notification-background .close-button:hover {
            background-color: alpha(@danger, 0.2);
          }

          .control-center .notification-row .notification-background .close-button:active {
            background-color: @danger;
          }

          progressbar,
          progress,
          trough {
            border-radius: 8px;
          }

          progressbar {
            background-color: rgba(255,255,255,.1);
          }

          .notification-group {
            margin: 2px 8px 2px 8px;
          }

          .notification-group-headers {
            font-weight: bold;
            font-size: 1.25rem;
            color: @fg;
            letter-spacing: 2px;
          }

          .notification-group-icon {
            color: @fg;
          }

          .notification-group-collapse-button,
          .notification-group-close-all-button {
            background: transparent;
            color: @fg;
            margin: 4px;
            border-radius: 8px;
            padding: 4px;
          }

          .notification-group-collapse-button:hover,
          .notification-group-close-all-button:hover {
            background: alpha(@accent, 0.15);
          }

          .widget-title {
            font-size: 1.2em;
            margin: 6px;
          }

          .widget-title button {
            background: alpha(@elevated, .4);
            border-radius: 8px;
            padding: 4px 16px;
          }

          .widget-title button:hover {
            background-color: alpha(@accent, 0.15);
          }

          .widget-title button:active {
            background-color: @accent;
          }

          .widget-dnd {
            margin: 6px;
            font-size: 1.2rem;
          }

          .widget-dnd > switch {
            background: alpha(@elevated, .4);
            font-size: initial;
            border-radius: 8px;
            box-shadow: none;
            padding: 2px;
          }

          .widget-dnd > switch:hover {
            background: alpha(@accent, 0.15);
          }

          .widget-dnd > switch:checked {
            background: @accent;
          }

          .widget-dnd > switch:checked:hover {
            background: alpha(@accent, 0.15);
          }

          .widget-dnd > switch slider {
            background: @fg;
            border-radius: 8px;
          }

          .widget-mpris {
            background: alpha(@elevated, 0.45);
            border-radius: 12px;
            color: @fg;
            margin: 20px 6px;
          }

          .widget-mpris-player {
            background-color: alpha(@bg, 0.6);
            border-radius: 12px;
            padding: 6px 14px;
            margin: 6px;
          }

          .widget-mpris > box > button {
            color: @fg;
            border-radius: 8px;
          }

          .widget-mpris button {
            color: alpha(@fg, .6);
          }

          .widget-mpris button:hover {
            color: @fg;
          }

          .widget-mpris-album-art {
            border-radius: 12px;
          }

          .widget-mpris-title {
            font-weight: 700;
            font-size: 1rem;
          }

          .widget-mpris-subtitle {
            font-weight: 500;
            font-size: 0.8rem;
          }

          picture.mpris-background {
            opacity: 0;
          }

          .widget-volume {
            background: alpha(@elevated, 0.4);
            color: @fg;
            padding: 4px;
            margin: 6px;
            border-radius: 8px;
          }

          .widget-backlight {
            background: alpha(@elevated, 0.4);
            color: @fg;
            padding: 4px;
            margin: 6px;
            border-radius: 8px;
          }
        '';
      };
    };
}
