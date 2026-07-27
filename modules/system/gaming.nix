{ inputs, ... }:
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:

    {
      nixpkgs.overlays = [ inputs.millennium.overlays.default ];

      programs.steam = {
        enable = true;
        package = pkgs.millennium-steam;
        gamescopeSession.enable = true;
      };

      programs.gamescope.enable = true;

      programs.gamemode.enable = true;

      programs.nix-ld.enable = true;
    }
;
}
