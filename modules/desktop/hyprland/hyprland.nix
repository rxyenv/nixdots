{
  flake.modules.homeManager.hyprland =
    {
      xdg.configFile."hypr/hyprland.lua".text = ''
        require("monitors")
        require("programs")
        require("autostart")
        require("environment")
        require("look")
        require("layouts")
        require("inputs")
        require("binds")
        require("rules")
      '';
    }
;
}
