{
  flake.modules.homeManager.hyprland =
    {
      xdg.configFile."hypr/layouts.lua".text = ''
        hl.config({
            dwindle = {
                force_split = 2,
                preserve_split = false,
            },
            master = {
                new_status = "master",
            },
        })
      '';
    }
;
}
