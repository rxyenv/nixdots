{
  flake.modules.homeManager.foot =
    { ... }:

    {
      programs.foot = {
        enable = true;
        server.enable = true;
        settings = {
          main = {
            font = "Maple Mono NF:size=16";
            shell = "fish";
            pad = "14x14 center";
          };
          cursor = {
            style = "block";
            unfocused-style = "hollow";
          };
          url = {
            launch = "xdg-open \${url}";
          };
          mouse = {
            hide-when-typing = "yes";
          };
          colors-dark = {
            foreground = "d4d9eb";
            background = "061115";
            regular0 = "0c171b";
            regular1 = "f38ba8";
            regular2 = "8bd5ca";
            regular3 = "ffd16d";
            regular4 = "448fff";
            regular5 = "b8b1ff";
            regular6 = "8bd5ca";
            regular7 = "d4d9eb";
            bright0 = "5a6070";
            bright1 = "f38ba8";
            bright2 = "8bd5ca";
            bright3 = "ffd16d";
            bright4 = "448fff";
            bright5 = "b8b1ff";
            bright6 = "8bd5ca";
            bright7 = "d4d9eb";
            alpha = 0.65;
          };
        };
      };
    };
}
