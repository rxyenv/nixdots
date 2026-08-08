{
  flake.modules.homeManager.helium =
    { pkgs, inputs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      home.packages = [ inputs.helium-browser.packages.${system}.default ];
    };
}
