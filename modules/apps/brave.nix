{
  flake.modules.homeManager.brave =
    { inputs, pkgs, ... }:
    {
      home.packages = [ inputs.brave-browser.packages.${pkgs.system}.brave-origin-beta ];
      home.sessionVariables.BROWSER = "brave-origin-beta";
    };
}
