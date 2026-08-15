{
  flake.modules.homeManager.abyssal-shell =
    { config, pkgs, ... }:
    {
      home.packages = [
        pkgs.quickshell
        (pkgs.writeShellApplication {
          name = "abyssal-shell";
          runtimeInputs = with pkgs; [
            quickshell
            networkmanager
            bluez
            wireplumber
          ];
          text = ''
            if (( $# > 0 )); then
              exec qs -p "$HOME/.config/quickshell/abyssal" ipc call shell "$@"
            fi
            exec quickshell -p "$HOME/.config/quickshell/abyssal"
          '';
        })
      ];

      # Keep the live Quickshell configuration outside the Nix store so edits
      # are picked up immediately by Quickshell's config reloader.
      xdg.configFile."quickshell/abyssal".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nixdots/modules/desktop/abyssal-shell";
    };
}
