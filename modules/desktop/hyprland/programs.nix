{
  flake.modules.homeManager.hyprland =
    {
      xdg.configFile."hypr/programs.lua".text = ''
        return {
          terminal = "foot",
          file_manager = "nautilus",
          browser = "zen",
        }
      '';
    }
;
}
