{
  flake.modules.homeManager.quickshell =
    {
      programs.quickshell = {
        enable = true;
        systemd.enable = true;
      };

      xdg.configFile."quickshell/shell.qml".source = ./shell.qml;

      # Restart on shell.qml changes; a symlink swap alone doesn't reload
      # the running instance
      systemd.user.services.quickshell.Unit.X-Restart-Triggers = [ "${./shell.qml}" ];
    };
}
