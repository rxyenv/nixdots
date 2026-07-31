{
  flake.modules.homeManager.iloader =
    { pkgs, inputs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      home.packages = [ inputs.iloader.packages.${system}.default ];
    };
}
