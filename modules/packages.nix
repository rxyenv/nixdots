{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    git           # optional, useful during installation
    wget
    curl
    unzip
    libsecret     # libraries
    libimobiledevice
    ifuse
  ];
}
