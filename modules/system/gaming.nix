{ inputs, ... }:
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:

    {
      nixpkgs.overlays = [ inputs.millennium.overlays.default ];

      programs.steam = {
        enable = true;
        package = pkgs.millennium-steam;
      };

      programs.gamemode.enable = true;

      programs.nix-ld.enable = true;
    }
;
}
