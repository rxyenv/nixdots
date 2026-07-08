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

    -- For Noctalia Color templates
    require("noctalia")
  '';
}
