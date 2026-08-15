{
  flake.modules.homeManager.hyprland = {
    xdg.configFile."hypr/look.lua".text = ''
      hl.config({
          general = {
              gaps_in = 10,
              gaps_out = 20,
              gaps_workspaces = 10,
              border_size = 2,
              resize_on_border = true,
              allow_tearing = false,
              layout = "dwindle",
          },
          decoration = {
              rounding = 18,
              rounding_power = 3,
              active_opacity = 0.97,
              inactive_opacity = 0.95,
              fullscreen_opacity = 0.97,
              shadow = {
                  enabled = true,
                  range = 25,
                  render_power = 3,
                  offset = { 0, 6 },
                  color = "rgba(000000aa)",
                  color_inactive = "rgba(00000066)",
              },
              blur = {
                  enabled = true,
                  size = 8,
                  passes = 3,
                  ignore_opacity = true,
                  new_optimizations = true,
                  vibrancy = 0.22,
                  vibrancy_darkness = 0.35,
                  xray = false,
              },
          },
          animations = {
              enabled = true,
          },
          misc = {
              force_default_wallpaper = 0,
              disable_hyprland_logo = true,
              animate_manual_resizes = true,
              animate_mouse_windowdragging = true,
              focus_on_activate = true,
              vrr = 1,
          },
      })

      hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
      hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
      hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
      hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
      hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

      -- Springs (damping ratio ~0.9: settles cleanly, whisper of overshoot)
      hl.curve("gentleSpring", { type = "spring", mass = 1, stiffness = 80, dampening = 16 })
      hl.curve("softSpring", { type = "spring", mass = 1, stiffness = 60, dampening = 14.7 })

      hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
      hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
      hl.animation({ leaf = "windows", enabled = true, speed = 4.2, spring = "gentleSpring" })
      hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.2, spring = "gentleSpring", style = "slide bottom" })
      hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "easeInOutCubic", style = "slide top" })
      hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
      hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
      hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
      hl.animation({ leaf = "layers", enabled = true, speed = 4, spring = "gentleSpring" })
      hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
      hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
      hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
      hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 3.2, spring = "softSpring", style = "slidevert" })
      hl.animation({
          leaf = "specialWorkspace",
          enabled = true,
          speed = 3,
          spring = "softSpring",
          style = "slidevert",
      })
    '';
  };
}
