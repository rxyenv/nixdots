{
  flake.modules.homeManager.fuzzel =
    {
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = "Maple Mono NF:size=13";
            width = 42;
            lines = 8;
            terminal = "foot -e";
            layer = "overlay";
            icon-theme = "Papirus-Dark";
            icons-enabled = true;
          };
          colors = {
            # Catppuccin Mocha
            background = "1e1e2eff";
            text = "cdd6f4ff";
            match = "89b4faff";
            selection = "313244ff";
            selection-text = "cdd6f4ff";
            selection-match = "89b4faff";
            border = "313244ff";
          };
          border = {
            width = 2;
            radius = 12;
          };
          dmenu = {
            exit-immediately-if-empty = true;
          };
        };
      };
    };
}
