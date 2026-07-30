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

      home.pointerCursor = {
        package = pkgs.capitaine-cursors;
        name = "capitaine-cursors-white";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };
    };
}
