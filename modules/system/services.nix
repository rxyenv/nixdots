{
  flake.modules.nixos.services =
    { ... }:

    {
      services.usbmuxd.enable = true;

      services.dbus.enable = true;

      services.gnome.gnome-keyring.enable = true;

      services.tuned.enable = true;

      services.upower.enable = true;

      services.gvfs.enable = true;

      services.udisks2.enable = true;

      services.colord.enable = true;

      services.gnome.at-spi2-core.enable = true;

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      networking.firewall = {
        allowedTCPPorts = [ 53317 ];
        allowedUDPPorts = [ 53317 ];
      };
    }
;
}
