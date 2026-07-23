{
  flake.modules.homeManager.hyprland =
    {
      xdg.configFile."hypr/rules.lua".text = ''
        -- ── Helpers ────────────────────────────────────────────────

        -- Blurred layer surface (transparent CSS behind, see ignore_alpha)
        local function blur_layer(name, namespace, alpha, extra)
          local rule = {
            name = name,
            match = { namespace = namespace },
            blur = true,
            ignore_alpha = alpha,
          }
          for k, v in pairs(extra or {}) do rule[k] = v end
          hl.layer_rule(rule)
        end

        -- Centered floating window, size as fraction of the monitor
        local function float_centered(name, match, w, h, extra)
          local rule = {
            name = name,
            match = match,
            float = true,
            center = true,
            size = { "monitor_w*" .. w, "monitor_h*" .. h },
          }
          for k, v in pairs(extra or {}) do rule[k] = v end
          hl.window_rule(rule)
        end

        -- ── Layer rules (blur for shell surfaces) ──────────────────

        blur_layer("waybar-blur", "^waybar$", 0.3, { blur_popups = true })
        blur_layer("walker-blur", "^walker$", 0.5)
        blur_layer("swayosd-blur", "^swayosd$", 0.2)
        blur_layer("swaync-blur", "^swaync-notification-window$", 0.5)
        blur_layer("swaync-cc-blur", "^swaync-control-center$", 0.5)

        hl.layer_rule({
          name = "no-anim-selection",
          match = { namespace = "selection" },
          no_anim = true,
        })

        -- ── Global window behavior ─────────────────────────────────

        hl.window_rule({
          name = "suppress-maximize-events",
          match = { class = ".*" },
          suppress_event = "maximize",
        })

        hl.window_rule({
          name = "airy-floating-windows",
          match = { float = true },
          rounding = 16,
          border_size = 3,
          opacity = "0.97 0.92",
        })

        hl.window_rule({
          name = "fix-xwayland-drags",
          match = {
            class = "^$",
            title = "^$",
            xwayland = true,
            float = true,
            fullscreen = false,
            pin = false,
          },
          no_focus = true,
        })

        -- ── Dialogs & popups ───────────────────────────────────────

        float_centered("common-dialogs",
          { title = "^(Open|Save|Save As|Choose|Select|File Upload)(.*)$" },
          0.55, 0.6, { opacity = "0.98 0.94" })

        hl.window_rule({
          name = "picture-in-picture",
          match = { title = "^(Picture-in-Picture|Picture in picture)$" },
          float = true,
          pin = true,
          size = { "monitor_w*0.28", "monitor_h*0.28" },
          move = { "monitor_w*0.7", "monitor_h*0.68" },
          opacity = "0.96 0.90",
        })

        -- ── Floating apps ──────────────────────────────────────────

        -- File managers / image viewer
        float_centered("float-file-managers",
          { class = "^(org.gnome.Nautilus|thunar|org.gnome.LoupeD)$", fullscreen = false },
          0.6, 0.65)

        -- TUI utilities (network, audio, bluetooth) + floating terminal
        float_centered("float-tui-tools",
          { class = "^(org.zen0x.impala|org.zen0x.wiremix|org.zen0x.bluetui|org.zen0x.floating-terminal)$" },
          0.55, 0.6)

        -- btop wants room for all its boxes
        float_centered("float-btop",
          { class = "^(org.zen0x.btop)$" },
          0.85, 0.85)

        -- Small utility windows
        float_centered("float-satty",
          { class = "^(com.gabm.satty)$", fullscreen = false },
          0.5, 0.6)
        float_centered("float-android-studio-welcome",
          { class = "^(jetbrains-studio)$", title = "^Welcome to Android Studio$", fullscreen = false },
          0.45, 0.55)
        float_centered("float-zed-settings",
          { class = "dev.zed.Zed", title = "Zed — Settings", fullscreen = false },
          0.55, 0.6)
        float_centered("float-nwg-look",
          { class = "^(nwg-look)$", fullscreen = false },
          0.6, 0.7)

        -- Media
        float_centered("float-spotify",
          { class = "^(Spotify)$", fullscreen = false },
          0.75, 0.75)

        hl.window_rule({
          name = "move-hyprland-run",
          match = { class = "hyprland-run" },
          move = { 20, "monitor_h-120" },
          float = true,
        })

        -- ── Steam ──────────────────────────────────────────────────

        local steam_class = "^(steam|Steam|steamwebhelper)$"

        float_centered("steam-floating",
          { class = steam_class },
          0.8, 0.8,
          {
            tag = "-default-opacity",
            opacity = "1 1",
            idle_inhibit = "fullscreen",
          })

        hl.window_rule({
          name = "steam-friends-size",
          match = { class = steam_class, title = "^Friends List$" },
          size = { "monitor_w*0.24", "monitor_h*0.74" },
        })

        -- ── Scratchpads ────────────────────────────────────────────

        -- Pin scratchpad apps (launched by the Super+Alt binds) to their
        -- special workspace, floating and centered
        for _, s in ipairs({ "term", "notes", "files", "mixer", "monitor" }) do
          hl.window_rule({
            name = "scratch-" .. s,
            match = { class = "^org%.zen0x%.scratch-" .. s .. "$" },
            workspace = "special:" .. s,
            float = true,
            center = true,
            size = { "monitor_w*0.65", "monitor_h*0.65" },
          })
        end

        -- ── Workspaces ─────────────────────────────────────────────

        -- Persistent workspaces 1-5
        for i = 1, 5 do
          hl.workspace_rule({
            workspace = tostring(i),
            persistent = true,
          })
        end

        local workspace_assignments = {
          { ws = "1", match = { class = "^(zen|Zen)$" } },
          { ws = "2", match = { class = "^(kitty|Kitty|Alacritty|WezTerm|foot)$" } },
          { ws = "3", match = { class = "^(dev%.zed%.Zed|org%.helix%.editor)$" } },
          { ws = "4", match = { class = "^(Spotify)$" } },
          { ws = "5", match = { class = "^(steam|Steam|heroic|Heroic)$" } },
          { ws = "6", match = { title = "^(.*%.exe|.*game|.*Game)$" } },
        }

        for _, a in ipairs(workspace_assignments) do
          hl.window_rule({
            name = "ws" .. a.ws,
            match = a.match,
            workspace = a.ws,
          })
        end
      '';
    }
;
}
