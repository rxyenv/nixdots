{
  flake.modules.homeManager.btop =
    {
      programs.btop = {
        enable = true;
        settings = {
          color_theme = "zen0x-current";
          theme_background = false;
          truecolor = true;
          vim_keys = true;
          rounded_corners = true;
          update_ms = 1500;
          proc_sorting = "cpu lazy";
          proc_tree = false;
          show_uptime = true;
          check_temp = true;
          show_gpu_info = "On";
          io_mode = false;
        };
      };
    }
;
}
