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
        piper         # logitech mouse config GUI
        unityhub      # Unity game engine hub
        nmap
        btrfs-progs
        parted
      ];

      services.ratbagd.enable = true;  # daemon piper talks to
      services.usbmuxd.enable = true;
    }
;
}
