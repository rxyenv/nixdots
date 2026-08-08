{
  flake.modules.homeManager.neovim =
    { pkgs, lib, ... }:
    let
      # Individual file symlinks (not a whole-dir symlink) so lazy.nvim can still
      # write lazy-lock.json / state into ~/.config/nvim alongside the vendored files.
      vendoredFiles = lib.filesystem.listFilesRecursive ./config;
      relPath = file: lib.removePrefix (toString ./config + "/") (toString file);
      configFileEntries = lib.listToAttrs (
        map (file: {
          name = "nvim/${relPath file}";
          value.source = file;
        }) vendoredFiles
      );
    in
    {
      home.packages = with pkgs; [
        neovim
        lazygit
        unzip
        gcc
      ];

      xdg.configFile = configFileEntries;
    }
;
}
