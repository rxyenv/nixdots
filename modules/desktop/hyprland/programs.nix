{
  flake.modules.homeManager.hyprland =
    {
      xdg.configFile."hypr/programs.lua".text = ''
        return {
          terminal = "kitty",
          file_manager = "nautilus",
          browser = "zen",
        }
      '';
    }
;
}
