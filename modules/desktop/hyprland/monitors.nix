{
  flake.modules.homeManager.hyprland =
    {
      xdg.configFile."hypr/monitors.lua".text = ''
        local function hdmi_connected()
          local p = io.popen("cat /sys/class/drm/card*-HDMI-A-1/status 2>/dev/null")
          if not p then
            return false
          end
          local out = p:read("*a")
          p:close()
          for line in out:gmatch("[^\n]+") do
            if line == "connected" then
              return true
            end
          end
          return false
        end

        if hdmi_connected() then
          hl.monitor({ output = "eDP-1", disabled = true })
          hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@180", position = "0x0", scale = "1", })
        else
          hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = "1", })
        end
      '';
    }
;
}
