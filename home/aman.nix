{
  imports = [
    ./programs/kitty.nix
    ./programs/hyprland
    ./programs/zsh.nix
  ];

  home.username = "aman";
  home.homeDirectory = "/home/aman";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
