{ ... }:

{
  xdg.configFile."noctalia/palettes/mocha.json".source = ../../files/noctalia/palettes/mocha.json;

  xdg.configFile."noctalia/config.toml".text = ''
    [widget.workspaces]
    display = "name"
    hide_empty_workspaces = true
  '';
}
