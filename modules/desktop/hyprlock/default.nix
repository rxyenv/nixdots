{
  flake.modules.homeManager.hyprlock =
    { ... }:

    {
      programs.hyprlock = {
        enable = true;
        extraConfig = ''
          general {
              hide_cursor = true
              grace = 3
              no_fade_in = false
              no_fade_out = false
              ignore_empty_input = true
              text_trim = true
          }

          background {
              monitor =
              path = $HOME/.config/hypr/wallpaper.jpg
              blur_size = 8
              blur_passes = 4
              brightness = 0.60
              noise = 0.04
              contrast = 0.90
              vibrancy = 0.22
              vibrancy_darkness = 0.40
          }

          # Clock
          label {
              monitor =
              text = cmd[update:1000] echo "<b>$(date +"%H:%M")</b>"
              color = rgba(f3edf7ee)
              font_size = 112
              font_family = Maple Mono NF
              position = 0, 260
              halign = center
              valign = center
              shadow_passes = 3
              shadow_size = 6
              shadow_color = rgba(070722bb)
              shadow_boost = 1.2
          }

          # Date
          label {
              monitor =
              text = cmd[update:60000] echo "$(date +"%A · %B %d, %Y")"
              color = rgba(7c80b4ee)
              font_size = 24
              font_family = Maple Mono NF
              position = 0, 130
              halign = center
              valign = center
              shadow_passes = 2
              shadow_size = 4
              shadow_color = rgba(07072299)
              shadow_boost = 1.1
          }

          # Divider
          label {
              monitor =
              text = ─────────────────
              color = rgba(11112d66)
              font_size = 14
              font_family = Maple Mono NF
              position = 0, 40
              halign = center
              valign = center
          }

          # User
          label {
              monitor =
              text =   $USER
              color = rgba(7c80b4cc)
              font_size = 17
              font_family = Maple Mono NF
              position = 0, -48
              halign = center
              valign = center
              shadow_passes = 1
              shadow_size = 3
              shadow_color = rgba(07072288)
          }

          # Password input
          input-field {
              monitor =
              size = 340, 58
              outline_thickness = 2
              dots_size = 0.30
              dots_spacing = 0.18
              dots_center = true
              dots_rounding = -1
              outer_color = rgba(fff59bcc)
              inner_color = rgba(070722bb)
              font_color = rgba(f3edf7ff)
              font_family = Maple Mono NF
              fade_on_empty = true
              fade_timeout = 1200
              placeholder_text = <span foreground="#7c80b4"><i>󰌾  Password</i></span>
              hide_input = false
              rounding = 14
              check_color = rgba(9bfeceff)
              fail_color = rgba(fd4663ff)
              fail_text = <span foreground="#fd4663"><b>$FAIL</b> ($ATTEMPTS)</span>
              fail_transition = 300
              capslock_color = rgba(fff59bff)
              numlock_color = rgba(fff59bff)
              bothlock_color = rgba(fd4663ff)
              swap_font_color = false
              position = 0, -135
              halign = center
              valign = center
          }
        '';
      };
    };
}
