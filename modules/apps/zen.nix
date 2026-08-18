{
  flake.modules.homeManager.zen =
    { pkgs, inputs, lib, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;

      bootloader-program = pkgs.fetchzip {
        url = "https://github.com/sineorg/bootloader/releases/download/v0.1.4/program.zip";
        hash = "sha256-6suI8iRxQr6L6uVIcs2WOWUjf6O5XipqjrHHGlKzQZc=";
        stripRoot = false;
      };

      bootloader-profile = pkgs.fetchzip {
        url = "https://github.com/sineorg/bootloader/releases/download/v0.1.4/profile.zip";
        hash = "sha256-yY8hdhSnFoqCoXh0AesMNTyeo89b70FZdTLZwKcSWsw=";
        stripRoot = false;
      };

      sine-engine = pkgs.fetchzip {
        url = "https://github.com/CosmoCreeper/Sine/releases/download/v2.3.3/engine.zip";
        hash = "sha256-FmUgS4nA+RkJyb53MlzuxFfRhKVxTRLXC+/7dchpXHw=";
        stripRoot = false;
      };

      zen-unwrapped = inputs.zen-browser.packages.${system}.zen-browser-unwrapped;

      # Sine bootloader goes through the wrapper's autoconfig (mozilla.cfg);
      # adding it to the unwrapped package gets clobbered by wrapFirefox.
      # The loader uses ChromeUtils, so the autoconfig sandbox must be off.
      zen-userchrome = pkgs.writeText "zen-userChrome.css" ''
        .titlebar-buttonbox-container,
        #titlebar-buttonbox,
        .titlebar-close,
        .titlebar-min,
        .titlebar-max,
        .titlebar-restore {
          display: none !important;
        }
      '';

      zen-browser =
        (pkgs.wrapFirefox zen-unwrapped {
          pname = "zen-browser";
          extraPrefs = builtins.readFile "${bootloader-program}/config.js" + ''
            defaultPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
          '';
        }).overrideAttrs
          (old: {
            buildCommand = old.buildCommand + ''
              for f in $out/lib/zen-*/defaults/pref/autoconfig.js; do
                echo 'pref("general.config.sandbox_enabled", false);' >> "$f"
              done
            '';
          });
    in
    {
      home.packages = [ zen-browser ];

      # Sine profile files (chrome/utils + chrome/JS) for each existing Zen profile.
      # Runs imperatively at activation because profile names are dynamic UUIDs.
      home.activation.sineSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -d "$HOME/.config/zen" ]; then
          for profile_dir in "$HOME"/.config/zen/*/; do
            if [ -f "$profile_dir/prefs.js" ]; then
              chrome_dir="$profile_dir/chrome"
              $DRY_RUN_CMD mkdir -p "$chrome_dir/utils" "$chrome_dir/sine-mods"
              # Earlier copies preserved nix-store read-only modes; make them writable
              [ -e "$chrome_dir/utils" ] && $DRY_RUN_CMD chmod -R u+w "$chrome_dir/utils"
              [ -e "$chrome_dir/JS" ] && $DRY_RUN_CMD chmod -R u+w "$chrome_dir/JS"
              $DRY_RUN_CMD cp -rf --no-preserve=mode,ownership ${bootloader-profile}/utils/. "$chrome_dir/utils/"
              $DRY_RUN_CMD cp -rf --no-preserve=mode,ownership ${sine-engine}/JS/. "$chrome_dir/JS/"
              $DRY_RUN_CMD cp -f --no-preserve=mode,ownership ${zen-userchrome} "$chrome_dir/hide-window-controls.css"
              # @import must come before other rules, so prepend it
              if ! grep -qs "hide-window-controls.css" "$chrome_dir/userChrome.css"; then
                if [ -s "$chrome_dir/userChrome.css" ]; then
                  $DRY_RUN_CMD sed -i '1i @import "hide-window-controls.css";' "$chrome_dir/userChrome.css"
                else
                  $DRY_RUN_CMD printf '@import "hide-window-controls.css";\n' > "$chrome_dir/userChrome.css"
                fi
              fi
            fi
          done
        fi
      '';
    };
}
