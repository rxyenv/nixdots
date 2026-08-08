{
  flake.modules.nixos.hardware =
    { pkgs, ... }:

    {
      services.udev.packages = [ pkgs.openrgb ];

      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;
      hardware.bluetooth.settings = {
        General.Experimental = true;
        Policy.AutoEnable = true;
      };
    }
;
}
