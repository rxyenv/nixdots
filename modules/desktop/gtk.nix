{
  flake.modules.homeManager.gtk =
    { pkgs, inputs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      abyssal = inputs.abyssal-gtk-theme.packages.${system}.default;
    in
    {
      gtk.enable = true;
      gtk.theme = {
        name = "Abyssal-Catppuccin";
        package = abyssal;
      };
      xdg.configFile."gtk-3.0/settings.ini".force = true;
      xdg.configFile."gtk-4.0/settings.ini".force = true;
      xdg.configFile."gtk-4.0/gtk.css".text = ''
        @import "${abyssal}/share/themes/Abyssal-Catppuccin/gtk-4.0/libadwaita.css";
      '';

      gtk.iconTheme = {
        name = "Yaru-purple-dark";
        package = pkgs.yaru-theme;
      };
    }
;
}
