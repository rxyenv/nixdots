{
  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      settings.user.name = "aman";
      settings.user.email = "amanchaitany@proton.me";
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
    };
  };
}
