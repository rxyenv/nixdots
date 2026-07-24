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
      };
      boot.loader.efi.canTouchEfiVariables = true;

      boot.kernelPackages = pkgs.linuxPackages_latest;
    }
;
}
