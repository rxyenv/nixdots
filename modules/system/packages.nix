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
        piper         # logitech mouse config GUI
        unityhub      # Unity game engine hub
        nmap
      ];

      services.ratbagd.enable = true;  # daemon piper talks to
    }
;
}
