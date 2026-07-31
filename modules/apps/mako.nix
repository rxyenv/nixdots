{
  flake.modules.homeManager.mako =
    { ... }:
    {
      services.mako = {
        enable = true;
        settings = {
          default-timeout = 5000;
          border-radius = 8;
          margin = "10";
          padding = "12,16";
          background-color = "#1e1e2e";
          text-color = "#cdd6f4";
          border-color = "#313244";
          progress-color = "over #313244";
        };
        extraConfig = ''
          [urgency=high]
          border-color=#f38ba8
          text-color=#f38ba8
        '';
      };
    };
}
