{ pkgs, ... }:

{
  home.packages = [ pkgs.fastfetch ];

  xdg.configFile."fastfetch/config.jsonc".source = ../../files/fastfetch/config.jsonc;
  xdg.configFile."fastfetch/logo.webp".source = ../../files/fastfetch/logo.webp;
}
