{
  flake.modules.homeManager.base = {
    home.username = "aman";
    home.homeDirectory = "/home/aman";
    home.stateVersion = "26.05";
    home.sessionPath = [ "$HOME/.local/bin" ];
    programs.man.generateCaches = false;
    programs.home-manager.enable = true;

    systemd.user.services.gnome-keyring-secrets = {
      Unit = {
        Description = "GNOME Keyring secrets component";
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --start --foreground --components=secrets";
        Restart = "on-abort";
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
