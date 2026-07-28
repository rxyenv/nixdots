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
          theme = "'noctalia'";
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
