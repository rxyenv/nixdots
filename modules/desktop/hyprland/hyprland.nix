{
  flake.modules.homeManager.hyprland =
    { config, pkgs, ... }:
    let
      configDir = "${config.home.homeDirectory}/nixdots/modules/desktop/hyprland/config";
      linkedLuaFiles = [
        "autostart"
        "binds"
        "environment"
        "hyprland"
        "inputs"
        "layouts"
        "look"
        "monitors"
        "programs"
        "rules"
      ];
    in
    {
      services.hyprpolkitagent.enable = true;

      xdg.configFile =
        builtins.listToAttrs (
          map (name: {
            name = "hypr/${name}.lua";
            value.source = config.lib.file.mkOutOfStoreSymlink "${configDir}/${name}.lua";
          }) linkedLuaFiles
        )
        // {
          "hypr/cs2-vulkan-fix.lua".text = builtins.replaceStrings
            [ "@CSGO_VULKAN_FIX@" ]
            [ "${pkgs.hyprlandPlugins.csgo-vulkan-fix}" ]
            (builtins.readFile ./config/cs2-vulkan-fix.lua);

          # Lua language server metadata: Hyprland provides `hl` at runtime.
          "hypr/.luarc.json".text = builtins.toJSON {
            workspace.library = [ "${pkgs.hyprland}/share/hypr/stubs" ];
            diagnostics.globals = [ "hl" ];
          };
        };
    };

  flake.modules.nixos.hyprland =
    { pkgs, ... }:
    {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
        config.common.default = "*";
      };
    };
}
