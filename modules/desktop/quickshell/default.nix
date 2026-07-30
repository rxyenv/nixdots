{
  flake.modules.homeManager.quickshell =
    { config, ... }:

    {
      programs.quickshell = {
        enable = true;
        systemd.enable = true;
        activeConfig = "shell";
        # Out-of-store symlink to the repo checkout: quickshell watches the
        # real files and hot-reloads on save, no rebuild or restart needed
        configs.shell =
          config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/nixdots/modules/desktop/quickshell/shell";
      };
    };
}
