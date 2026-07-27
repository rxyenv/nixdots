{
  flake.modules.homeManager.claude =
    { pkgs, lib, ... }:
    {
      home.file.".claude/.i-have-adhd-always".text = "";

      home.activation.claudePluginIHaveADHD = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        _claude="/etc/profiles/per-user/$USER/bin/claude"
        _known="$HOME/.claude/plugins/known_marketplaces.json"
        _installed="$HOME/.claude/plugins/installed_plugins.json"

        if [ ! -x "$_claude" ]; then
          echo "claude-code not found at $_claude, skipping plugin setup"
          return 0
        fi

        if ! [ -f "$_known" ] || ! ${pkgs.jq}/bin/jq -e '."i-have-adhd"' "$_known" > /dev/null 2>&1; then
          echo "Adding i-have-adhd marketplace..."
          "$_claude" plugin marketplace add ayghri/i-have-adhd --scope user || true
        fi

        if ! [ -f "$_installed" ] || ! ${pkgs.jq}/bin/jq -e '.plugins["i-have-adhd@i-have-adhd"]' "$_installed" > /dev/null 2>&1; then
          echo "Installing i-have-adhd plugin..."
          "$_claude" plugin install i-have-adhd --scope user || true
        fi
      '';
    };
}
