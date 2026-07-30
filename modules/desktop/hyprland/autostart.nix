{
  flake.modules.homeManager.hyprland =
    {
      services.hyprpolkitagent.enable = true;

      xdg.configFile."hypr/autostart.lua".text = ''
        hl.on("hyprland.start", function()
            hl.exec_cmd("uwsm app -- foot --server")
            hl.exec_cmd("uwsm app -- udiskie --no-automount --smart-tray")
            hl.exec_cmd("wl-paste --type text --watch cliphist store")
            hl.exec_cmd("wl-paste --type image --watch cliphist store")
            hl.exec_cmd("uwsm app -- awww-daemon")
            -- restore last wallpaper after awww-daemon is ready
            hl.exec_cmd([[bash -c 'for i in $(seq 20); do awww query >/dev/null 2>&1 && break; sleep 0.1; done; WP=$(readlink -f "$HOME/.config/hypr/wallpaper" 2>/dev/null); [ -f "$WP" ] && awww img "$WP"']])
            -- reload config on monitor hotplug so monitors.lua re-evaluates
            hl.exec_cmd([[bash -c 'socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do case "$line" in monitoradded*|monitorremoved*) hyprctl reload ;; esac; done']])
        end)
      '';
    }
;
}
