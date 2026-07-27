{
  flake.modules.nixos.plymouth =
    { pkgs, ... }:

    let
      nixos-mac-style = pkgs.stdenvNoCC.mkDerivation {
        pname = "plymouth-nixos-mac-style";
        version = "unstable-2026-07-12";

        src = ./nixos-mac-style;

        installPhase = ''
          themeDir=$out/share/plymouth/themes/nixos-mac-style
          mkdir -p $themeDir
          cp -r images nixos-mac-style.plymouth $themeDir/
          substituteInPlace $themeDir/nixos-mac-style.plymouth \
            --replace-fail /usr/share/plymouth/themes $out/share/plymouth/themes
        '';
      };
    in
    {
      boot.plymouth = {
        enable = true;
        theme = "nixos-mac-style";
        themePackages = [ nixos-mac-style ];
      };

      boot.kernelParams = [ "quiet" ];
      boot.consoleLogLevel = 3;
      boot.initrd.verbose = false;
    }
;
}
