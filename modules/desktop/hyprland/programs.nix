{
  flake.modules.homeManager.hyprland =
    {
      xdg.configFile."hypr/programs.lua".text = ''
        return {
          terminal = "footclient",
          file_manager = "nautilus",
          browser = "zen",
        }
      '';
    }
;
}
