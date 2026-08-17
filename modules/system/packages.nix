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
        efibootmgr
        btrfs-progs
        parted
        ntfs3g
        bubblewrap
        unityhub
        mono
        dotnet-sdk
      ];

      services.ratbagd.enable = true;  # daemon piper talks to
      services.usbmuxd.enable = true;
    }
;
}
