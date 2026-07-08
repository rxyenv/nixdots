{ pkgs, config, ... }:

{
  imports = [
    ./programs/kitty.nix
    ./programs/hyprland
    ./programs/fish.nix
    ./programs/fastfetch.nix
    ./programs/noctalia.nix
    ./programs/neovim
    ./packages.nix
  ];

  home.username = "aman";
  home.homeDirectory = "/home/aman";
  home.stateVersion = "26.05";
  home.sessionPath = [ "$HOME/.local/bin" ];
  programs.man.generateCaches = false;
  programs.home-manager.enable = true;
}
