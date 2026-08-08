{
  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      settings.user.name = "aman";
      settings.user.email = "amanchaitany@proton.me";
    };
  };
}
