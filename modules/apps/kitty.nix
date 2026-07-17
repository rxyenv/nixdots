{
  flake.modules.homeManager.kitty =
    { lib, ... }:

    {
      programs.kitty = {
        enable = true;
        shellIntegration.enableFishIntegration = true;
        settings = {
          font_family = "Maple Mono NF";
          font_size = 16;
          cursor_shape = "block";
          cursor_shape_unfocused = "hollow";
          cursor_trail = 1;
          background_opacity = "0.65";
          detect_urls = "yes";
          show_hyperlink_targets = "no";
          underline_hyperlinks = "hover";
          hide_window_decorations = "yes";
          window_padding_width = "14 14";
          single_window_margin_width = "30 0 0 0";
          shell = "fish";
        };
        # DMS (niri session) and noctalia (hyprland session) both write theme
        # files at runtime; include both, whichever shell ran last wins
        extraConfig = ''
          include dank-theme.conf
          include dank-tabs.conf
          include themes/noctalia.conf
        '';
      };

      # pre-create runtime theme files so includes never dangle
      home.activation.kittyThemeStubs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.config/kitty/themes"
        for f in dank-theme.conf dank-tabs.conf themes/noctalia.conf; do
          [ -e "$HOME/.config/kitty/$f" ] || touch "$HOME/.config/kitty/$f"
        done
      '';
    }
;
}
