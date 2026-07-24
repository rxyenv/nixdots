{
  flake.modules.homeManager.hyprland =
    {
      xdg.configFile."hypr/binds.lua".text = ''
        local programs = require("programs")

        local mainMod = "SUPER"

        hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(programs.terminal))
        hl.bind(
            mainMod .. " + SHIFT + Return",
            hl.dsp.exec_cmd(programs.terminal .. " --class org.zen0x.floating-terminal")
        )
        hl.bind(mainMod .. " + W", hl.dsp.window.close())
        hl.bind(
            mainMod .. " + SHIFT + M",
            hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || uwsm stop")
        )
        hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.file_manager))
        hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))
        hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())

        hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("uwsm-app -- walker"))
        hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
        hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("zeditor"))
        hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("kitty --class org.helix.editor -e hx"))
        hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd("zen0x-powermenu"))
        hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("zen0x-launch-audio"))
        hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("zen0x-launch-bluetooth"))
        hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("zen0x-launch-wifi"))

        hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
        hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
        hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
        hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

        hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "l" }))
        hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "r" }))
        hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "u" }))
        hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "d" }))

        for i = 1, 10 do
            local key = i % 10 -- 10 maps to key 0
            hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
            hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
        end

        -- Semantic scratchpads: toggle special workspace, autolaunch app when empty
        -- (window rules pin the org.zen0x.scratch-* classes to their special workspace)
        local scratchpads = {
            { key = 1, name = "term",    cmd = programs.terminal .. " --class org.zen0x.scratch-term" },
            { key = 2, name = "notes",   cmd = programs.terminal .. " --class org.zen0x.scratch-notes -e hx" },
            { key = 3, name = "files",   cmd = programs.terminal .. " --class org.zen0x.scratch-files -e yazi" },
            { key = 4, name = "mixer",   cmd = programs.terminal .. " --class org.zen0x.scratch-mixer -e wiremix" },
            { key = 5, name = "monitor", cmd = programs.terminal .. " --class org.zen0x.scratch-monitor -e btop" },
        }
        for _, s in ipairs(scratchpads) do
            hl.bind(mainMod .. " + ALT + " .. s.key, function()
                local wins = hl.get_workspace_windows("special:" .. s.name)
                if wins == nil or #wins == 0 then
                    hl.dispatch(hl.dsp.exec_cmd(s.cmd))
                else
                    hl.dispatch(hl.dsp.workspace.toggle_special(s.name))
                end
            end)
            hl.bind(
                mainMod .. " + ALT + SHIFT + " .. s.key,
                hl.dsp.window.move({ workspace = "special:" .. s.name, follow = false })
            )
        end

        hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("zen0x-capture-screenshot region"))
        hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("zen0x-capture-screenshot window"))
        hl.bind("CTRL + Print", hl.dsp.exec_cmd("zen0x-capture-screenshot fullscreen"))
        hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("zen0x-capture-screenrecording region"))
        hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("zen0x-capture-screenrecording fullscreen"))
        hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("zen0x-toggle-nightlight"))
        hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("zen0x-theme-menu"))
        hl.bind(mainMod .. " + CTRL + Escape", hl.dsp.exec_cmd("systemctl suspend"))
        hl.bind(mainMod .. " + ALT + A", hl.dsp.exec_cmd("easyeffects"))

        hl.bind(mainMod .. " + LEFT", hl.dsp.focus({ direction = "l" }))
        hl.bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "r" }))
        hl.bind(mainMod .. " + UP", hl.dsp.focus({ direction = "u" }))
        hl.bind(mainMod .. " + DOWN", hl.dsp.focus({ direction = "d" }))

        hl.bind(mainMod .. " + SHIFT + LEFT", hl.dsp.window.swap({ direction = "l" }))
        hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.swap({ direction = "r" }))
        hl.bind(mainMod .. " + SHIFT + UP", hl.dsp.window.swap({ direction = "u" }))
        hl.bind(mainMod .. " + SHIFT + DOWN", hl.dsp.window.swap({ direction = "d" }))

        hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("zen0x-clipboard"))
        hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
        hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
        hl.bind(mainMod .. " + Tab", function()
            if hl.plugin and hl.plugin.scrolloverview then
                hl.plugin.scrolloverview.overview("toggle")
            end
        end)

        hl.bind("Print", hl.dsp.exec_cmd("zen0x-capture-screenshot smart"))
        hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
        hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

        hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
        hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"))
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"))
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("zen0x-brightness-display +5%"))
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("zen0x-brightness-display 5%-"))
        hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"))

        hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
        hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
        hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
        hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

        hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"))
      '';
    }
;
}
