{
  flake.modules.homeManager.gtk =
    { pkgs, ... }:
    {
      # Theme packages
      home.packages = [
        pkgs.adw-gtk3
        pkgs.yaru-theme
        pkgs.capitaine-cursors
      ];

      gtk = {
        theme = {
          package = pkgs.adw-gtk3;
          name = "adw-gtk3-dark";
        };
        iconTheme = {
          package = pkgs.yaru-theme;
          name = "Yaru-dark";
        };
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
