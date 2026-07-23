{
  flake.modules.homeManager.theme =
    {
      pkgs,
      lib,
      ...
    }:

    let
      themeDir = ./.;
      python = pkgs.python3;
    in
    {
      home.activation.generateTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${python}/bin/python3 ${themeDir}/generate-theme.py catppuccin
      '';

      home.packages = [
        (pkgs.writeShellScriptBin "zen0x-generate-theme" ''
          exec ${python}/bin/python3 ${themeDir}/generate-theme.py "$@"
        '')

        (pkgs.writeShellScriptBin "zen0x-apply-theme" ''
          set -euo pipefail
          if [ "$#" -ne 1 ]; then
            echo "Usage: zen0x-apply-theme <theme>" >&2
            echo "Available themes:" >&2
            ls ${themeDir}/palettes/ | sed 's/\.toml$//' | sort >&2
            exit 2
          fi
          THEME="$1"
          zen0x-generate-theme "$THEME"
          mkdir -p "$HOME/.config/zen0x"
          printf '%s\n' "$THEME" > "$HOME/.config/zen0x/current-theme"

          # GTK: live-switch via gsettings (settings.ini/gtk.css already
          # rewritten by the generator from palette [meta])
          toml="${themeDir}/palettes/$THEME.toml"
          gtk_theme=$(sed -n 's/^gtk_theme = "\(.*\)"/\1/p' "$toml")
          icon_theme=$(sed -n 's/^icon_theme = "\(.*\)"/\1/p' "$toml")
          zed_theme=$(sed -n 's/^zed_theme = "\(.*\)"/\1/p' "$toml")
          if [ -n "$gtk_theme" ]; then
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" || true
          fi
          if [ -n "$icon_theme" ]; then
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" || true
          fi

          # Light/dark preference follows the palette variant
          variant=$(sed -n 's/^variant = "\(.*\)"/\1/p' "$toml")
          if [ "$variant" = "light" ]; then
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-light" || true
          else
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" || true
          fi

          # Wallpaper per theme (optional key; relative paths live in the repo)
          wallpaper=$(sed -n 's/^wallpaper = "\(.*\)"/\1/p' "$toml")
          wallpaper="''${wallpaper/#\~/$HOME}"
          case "$wallpaper" in
            ""|/*) ;;
            *) wallpaper="${themeDir}/$wallpaper" ;;
          esac
          if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
            zen0x-set-wallpaper "$wallpaper" || true
          fi

          # Zed: patch theme in settings.json (JSONC — sed, not jq).
          # Write in place via cp: sed -i replaces the inode and kills
          # Zed's settings watcher, breaking hot reload for later switches.
          zed_settings="$HOME/.config/zed/settings.json"
          if [ -n "$zed_theme" ] && [ -f "$zed_settings" ]; then
            zed_tmp=$(mktemp)
            sed "s/^\(\s*\"theme\":\s*\)\"[^\"]*\"/\1\"$zed_theme\"/" "$zed_settings" > "$zed_tmp"
            cp "$zed_tmp" "$zed_settings"
            rm -f "$zed_tmp"
          fi

          zen0x-theme-reload
        '')

        (pkgs.writeShellScriptBin "zen0x-theme-menu" ''
          set -euo pipefail
          current=$(cat "$HOME/.config/zen0x/current-theme" 2>/dev/null || true)
          selected=$(ls ${themeDir}/palettes/ | sed 's/\.toml$//' | sort | while IFS= read -r theme; do
            if [ "$theme" = "$current" ]; then
              echo "✓  $theme"
            else
              echo "   $theme"
            fi
          done | walker --dmenu --nosearch --width 280 --maxheight 420)
          [ -z "$selected" ] && exit 0
          selected="$(printf '%s' "$selected" | sed 's/^[[:space:]✓]*//')"
          zen0x-apply-theme "$selected"
        '')
      ];
    };
}
