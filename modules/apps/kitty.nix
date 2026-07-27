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
          background_opacity = 0.65;
          detect_urls = "yes";
          show_hyperlink_targets = "no";
          underline_hyperlinks = "hover";
          hide_window_decorations = "yes";
          window_padding_width = "14 14";
          single_window_margin_width = "30 0 0 0";
          shell = "fish";
        };
        # DMS (niri session) writes dank-theme/tabs at runtime
        # noctalia writes themes/noctalia.conf at startup
        extraConfig = ''
          include dank-theme.conf
          include dank-tabs.conf
          include themes/noctalia.conf
        '';
      };

      # pre-create runtime theme files so includes never dangle on first launch
      home.activation.kittyThemeStubs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        for f in dank-theme.conf dank-tabs.conf; do
          [ -e "$HOME/.config/kitty/$f" ] || touch "$HOME/.config/kitty/$f"
        done
        mkdir -p "$HOME/.config/kitty/themes"
        [ -e "$HOME/.config/kitty/themes/noctalia.conf" ] || touch "$HOME/.config/kitty/themes/noctalia.conf"
      '';
    }
;
}
