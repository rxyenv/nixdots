{
  flake.modules.nixos.boot =
    { lib, pkgs, ... }:

    let
      onePiecePlymouth = pkgs.stdenvNoCC.mkDerivation {
        pname = "onepiece-plymouth";
        version = "2026-06-19";

        src = pkgs.fetchFromGitHub {
          owner = "Anxhul10";
          repo = "onePiece-plymouth";
          rev = "ec9358d88e82367ba252781491654717605c719e";
          hash = "sha256-eZVLorbgnEz7Aff30j+PV2NNi8BuT6KgXJ0vmjncQfs=";
        };

        installPhase = ''
          runHook preInstall

          themeDir="$out/share/plymouth/themes/onePiece-plymouth"
          mkdir -p "$themeDir"
          cp -r media "$themeDir/"
          cp onePiece-plymouth.script "$themeDir/"
          substitute onePiece-plymouth.plymouth \
            "$themeDir/onePiece-plymouth.plymouth" \
            --replace-fail "/usr/share/plymouth/themes/onePiece-plymouth" "$themeDir"

          runHook postInstall
        '';
      };
    in
    {
      # Keep systemd-boot as the sole boot loader.  This explicit override also
      # prevents another imported module from re-enabling the old GRUB setup.
      boot.loader.grub.enable = lib.mkForce false;
      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      boot.loader.timeout = 0;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.kernelPackages = pkgs.linuxPackages_latest;

      boot.plymouth = {
        enable = true;
        theme = "onePiece-plymouth";
        themePackages = [ onePiecePlymouth ];
      };
    };
}
