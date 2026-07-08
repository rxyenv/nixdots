{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
    lazygit
    unzip
    gcc
  ];

  xdg.configFile."nvim".source = ./files;
}
