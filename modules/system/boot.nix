{
  flake.modules.nixos.boot =
    { lib, pkgs, ... }:

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

      boot.kernelPackages = pkgs.linuxPackages_zen;
    };
}
