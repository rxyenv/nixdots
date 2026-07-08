{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # CLI utilities
    bat
    btop
    fd
    grc
    jq
    localsend
    nixfmt
    ripgrep
    sassc
    nodejs
    github-cli

    # Rust
    rustup

    # AI
    claude-code
    opencode

    # Files
    nautilus

    # Browser
    librewolf

    # Theming
    pywalfox-native
    nwg-look

    # Editors
    vscode

    # Desktop
    glib
    signal-desktop
    xwayland-satellite

    # Flake packages
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
