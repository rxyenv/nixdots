{
  flake.modules.nixos.boot =
    { pkgs, ... }:

    {
      boot.loader.systemd-boot.enable = false;
      boot.loader.grub.enable = false;

      boot.loader.limine = {
        enable = true;
        efiSupport = true;
        maxGenerations = 10;
        resolution = "1920x1080";

        # Catppuccin Mocha
        style = {
          wallpapers = [ ];
          backdrop = "1e1e2e";
          interface = {
            resolution = "1920x1080";
            brandingColor = "89b4fa";
            helpColor = "a6adc8";
            helpColorBright = "cdd6f4";
          };
          graphicalTerminal = {
            foreground = "cdd6f4";
            background = "001e1e2e";
            brightForeground = "cdd6f4";
            brightBackground = "00313244";
            palette = "45475a;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;bac2de";
            brightPalette = "585b70;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;a6adc8";
          };
        };
      };
      boot.loader.efi.canTouchEfiVariables = true;

      boot.kernelPackages = pkgs.linuxPackages_latest;
    }
;
}
