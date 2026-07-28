{ inputs, ... }:

{
  flake.modules.homeManager.noctalia = {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      settings = {
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
          templates = {
            enable_builtin_templates = true;
            builtin_ids = [ "btop" "cava" ];
          };
        };
        wallpaper.enabled = true;
      };
    };
  };
}
