{
  flake.modules.homeManager.gtk =
    { inputs, pkgs, ... }:
    let
      abyssal-gtk-theme = inputs.abyssal-gtk-theme.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      # Theme packages
      home.packages = [
        abyssal-gtk-theme
        pkgs.yaru-theme
        pkgs.capitaine-cursors
      ];

      gtk = {
        theme = {
          package = abyssal-gtk-theme;
          name = "Abyssal-Default";
        };
        iconTheme = {
          package = pkgs.yaru-theme;
          name = "Yaru-dark";
        };
      };

      # Libadwaita does not honor the regular GTK theme setting.
      xdg.configFile."gtk-4.0/gtk.css" = {
        force = true;
        text = ''
          @import "${abyssal-gtk-theme}/share/themes/Abyssal-Default/gtk-4.0/libadwaita.css";
        '';
      };

      home.pointerCursor = {
        package = pkgs.capitaine-cursors;
        name = "capitaine-cursors-white";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };
    };
}
