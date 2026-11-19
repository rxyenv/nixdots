{
  flake.modules.homeManager.zen =
    { inputs, ... }:
    {
      imports = [ inputs.zen-browser.homeModules.beta ];

      programs.zen-browser = {
        enable = true;
        profiles.default = {
          isDefault = true;
          settings."zen.view.experimental-no-window-controls" = true;
          sine = {
            enable = true;
            mods = [
              "unloaded-tabs"
              "remove-tabs-separator"
            ];
          };
        };
      };

      home.sessionVariables.BROWSER = "zen-beta";
    };
}
