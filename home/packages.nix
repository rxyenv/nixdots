{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # CLI utilities
    bat
    codex
    curl
    fd
    git
    grc
    jq
    fastfetch
    localsend
    nixfmt
    ripgrep
    wget
    sassc

    # Files
    nautilus

    # Browser
    librewolf

    # Terminal
    kitty

    # Theming
    pywalfox-native
    nwg-look

    # Editors
    neovim
    vscode

    # Desktop
    glib
    signal-desktop
    xwayland-satellite

    # iPhone
    ifuse
    libimobiledevice

    # Libraries
    libsecret

    # Flake packages
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
