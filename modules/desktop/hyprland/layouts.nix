{
  flake.modules.homeManager.hyprland =
    {
      xdg.configFile."hypr/layouts.lua".text = ''
        hl.config({
            dwindle = {
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
