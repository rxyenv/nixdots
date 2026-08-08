{
  flake.modules.homeManager.hyprland =
    {
      xdg.configFile."hypr/layouts.lua".text = ''
        hl.config({
            dwindle = {
                preserve_split = true,
            },
            master = {
                new_status = "master",
            },
        })
      '';
    }
;
}
