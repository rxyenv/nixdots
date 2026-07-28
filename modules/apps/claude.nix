{
  flake.modules.homeManager.claude =
    { pkgs, lib, ... }:
    {
      home.file.".claude/.i-have-adhd-always".text = "";

      home.file.".claude/statusline-command.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          input=$(cat)

          user=$(whoami)
          host=$(hostname -s)
          cwd=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.cwd // .workspace.current_dir // empty')
          [ -z "$cwd" ] && cwd=$(pwd)

          home="$HOME"
          display_dir="''${cwd/#$home/\~}"

          git_branch=""
          if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
            git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
          fi

          repo=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end // empty')
          model=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.model.display_name // empty')
          used_pct=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.context_window.used_percentage // empty')

          parts=""
          parts+=$(printf '\033[32m%s@%s\033[0m' "$user" "$host")
          parts+=$(printf ' \033[34m%s\033[0m' "$display_dir")

          if [ -n "$git_branch" ]; then
            if [ -n "$repo" ]; then
              parts+=$(printf ' \033[33m(%s:%s)\033[0m' "$repo" "$git_branch")
            else
              parts+=$(printf ' \033[33m(%s)\033[0m' "$git_branch")
            fi
          fi

          if [ -n "$model" ]; then
            parts+=$(printf ' \033[36m[%s]\033[0m' "$model")
          fi

          if [ -n "$used_pct" ]; then
            used_int=$(printf '%.0f' "$used_pct")
            parts+=$(printf ' ctx:%s%%' "$used_int")
          fi

          if [ -f "$HOME/.claude/.i-have-adhd-always" ]; then
            parts+=$(printf ' \033[35m[ADHD]\033[0m')
          fi

          printf '%s' "$parts"
        '';
      };

      home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        _settings="$HOME/.claude/settings.json"
        if [ ! -f "$_settings" ]; then
          echo '{}' > "$_settings"
        fi
        _cmd="bash $HOME/.claude/statusline-command.sh"
        _tmp=$(${pkgs.jq}/bin/jq --arg cmd "$_cmd" \
          '. * {"statusLine": {"type": "command", "command": $cmd}}' "$_settings")
        echo "$_tmp" > "$_settings"
      '';

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
