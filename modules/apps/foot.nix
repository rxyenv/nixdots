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
            include = "~/.config/foot/themes/noctalia";
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
            alpha = 0.65;
          };
        };
      };
    };
}
