{
  flake.modules.homeManager.gtk =
    { pkgs, ... }:
    {
      # Theme packages; noctalia writes noctalia.css and sets adw-gtk3 via gsettings
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
