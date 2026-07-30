{
  flake.modules.homeManager.cava = {
    programs.cava = {
      enable = true;
      settings = {
        general = {
          framerate = 60;
          autosens = 1;
          bar_height = 32;
          bar_width = 2;
          bar_spacing = 1;
          bar_delimiter = 0;
          monstercat = 1;
          waves = 0;
          sleep_timer = 0;
        };

        input = {
          method = "pipewire";
          source = "auto";
        };

        output = {
          method = "ncurses";
          channels = "stereo";
          mono_option = "average";
        };

        color = {
          gradient = 1;
          gradient_count = 4;
          gradient_color_1 = "'#89b4fa'";
          gradient_color_2 = "'#cba6f7'";
          gradient_color_3 = "'#f5c2e7'";
          gradient_color_4 = "'#f38ba8'";
        };

        smoothing = {
          integral = 77;
          monstercat = 1.5;
          waves = 0;
          gravity = 100;
          noise_reduction = 77;
        };
      };
    };
  };
}
