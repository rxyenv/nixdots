{
  home.file.".config/kitty/current-theme.conf".text = ''
    # Catppuccin Mocha
    background #1e1e2e
    foreground #cdd6f4
    selection_background #585b70
    selection_foreground #cdd6f4
    cursor #f5e0dc
    cursor_text_color #1e1e2e

    color0 #45475a
    color1 #f38ba8
    color2 #a6e3a1
    color3 #f9e2af
    color4 #89b4fa
    color5 #f5c2e7
    color6 #94e2d5
    color7 #bac2de
    color8 #585b70
    color9 #f38ba8
    color10 #a6e3a1
    color11 #f9e2af
    color12 #89b4fa
    color13 #f5c2e7
    color14 #94e2d5
    color15 #a6adc8
  '';

  programs.kitty = {
    enable = true;
    extraConfig = ''
      include current-theme.conf
    '';
    settings = {
      font_family = "JetBrainsMono Nerd Font Mono";
      font_size = 13;
      cursor_shape = "block";
      cursor_shape_unfocused = "hollow";
      cursor_trail = 1;
      background_opacity = "0.97";
      detect_urls = "yes";
      show_hyperlink_targets = "no";
      underline_hyperlinks = "hover";
      hide_window_decorations = "yes";
      window_padding_width = "14 14";
      single_window_margin_width = "30 0 0 0";
    };
  };
}
