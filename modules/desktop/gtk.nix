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
          name = "Abyssal-Catppuccin";
        };
        iconTheme = {
          package = pkgs.yaru-theme;
          name = "Yaru-purple";
        };
      };

      # Libadwaita does not honor the regular GTK theme setting.
      xdg.configFile."gtk-4.0/gtk.css" = {
        force = true;
        text = ''
          @import "${abyssal-gtk-theme}/share/themes/Abyssal-Catppuccin/gtk-4.0/libadwaita.css";
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
