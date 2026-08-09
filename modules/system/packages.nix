{
  flake.modules.nixos.packages =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        git           # optional, useful during installation
        wget
        curl
        unzip
        libsecret     # libraries
        libimobiledevice
        ifuse
        idevicerestore
        libirecovery
        unityhub      # Unity game engine hub
        nmap
        btrfs-progs
        parted
        woeusb-ng
        persepolis
        ntfs3g
        bubblewrap
      ];

      services.ratbagd.enable = true;  # daemon piper talks to
      services.usbmuxd.enable = true;
    }
;
}
