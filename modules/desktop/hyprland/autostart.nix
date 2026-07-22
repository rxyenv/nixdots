{
  flake.modules.homeManager.hyprland =
    {
      xdg.configFile."hypr/autostart.lua".text = ''
        hl.on("hyprland.start", function()
            hl.exec_cmd("uwsm app -- swaync")
            hl.exec_cmd("zen0x-set-wallpaper ~/Pictures/Wallpapers/dragon.jpg")
            hl.exec_cmd("/run/current-system/sw/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
            hl.exec_cmd("wl-paste --type text --watch cliphist store")
            hl.exec_cmd("wl-paste --type image --watch cliphist store")
            hl.exec_cmd("hyprctl setcursor Sunset-cursors 24")
            -- reload config on monitor hotplug so monitors.lua re-evaluates
            hl.exec_cmd([[bash -c 'socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do case "$line" in monitoradded*|monitorremoved*) hyprctl reload ;; esac; done']])
        end)
      '';
    }
;
}
