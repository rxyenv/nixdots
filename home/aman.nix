{
  imports = [
    ./programs/kitty.nix
    ./programs/hyprland
    ./programs/fish.nix
  ];

  home.username = "aman";
  home.homeDirectory = "/home/aman";
  home.stateVersion = "26.05";
  programs.man.generateCaches = false;
  programs.home-manager.enable = true;
}
