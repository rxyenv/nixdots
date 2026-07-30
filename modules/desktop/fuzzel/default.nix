{
  flake.modules.homeManager.fuzzel =
    {
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            dpi-aware = "no";
            icon-theme = "Papirus-Dark";
            width = 50;
            font = "Maple Mono NF:weight=bold:size=16";
            line-height = 35;
            fields = "name,generic,comment,categories,filename,keywords";
            terminal = "footclient";
            prompt = "❯   ";
            show-actions = "yes";
            exit-on-keyboard-focus-loss = "no";
          };
          colors = {
            background = "1e1e2edd";
            text = "cdd6f4ff";
            prompt = "bac2deff";
            placeholder = "7f849cff";
            input = "cdd6f4ff";
            match = "fab387ff";
            selection = "585b70ff";
            selection-text = "cdd6f4ff";
            selection-match = "fab387ff";
            counter = "7f849cff";
            border = "fab387ff";
          };
        };
      };
    };
}
