{
  flake.modules.homeManager.hyprland =
    { pkgs, ... }:
    {
      xdg.configFile."hypr/cs2-vulkan-fix.lua".text = builtins.replaceStrings
        [ "@CSGO_VULKAN_FIX@" ]
        [ "${pkgs.hyprlandPlugins.csgo-vulkan-fix}" ]
        (builtins.readFile ./cs2-vulkan-fix.lua);

      xdg.configFile."hypr/hyprland.lua".text = ''
        require("cs2-vulkan-fix")
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
