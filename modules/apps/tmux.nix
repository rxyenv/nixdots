{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:

    {
      programs.tmux = {
        enable = true;
        clock24 = true;
        escapeTime = 0;
        historyLimit = 100000;
        keyMode = "vi";
        mouse = true;
        prefix = "C-s";
        sensibleOnTop = false;
        shell = "${pkgs.fish}/bin/fish";
        terminal = "tmux-256color";

        extraConfig = ''
          set -g focus-events on
          set -g renumber-windows on
          set -g set-clipboard on
          set -as terminal-features ',xterm-256color:RGB'

          # Pane and window controls.
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R
          bind p previous-window
          bind n next-window
          bind Tab next-window
          bind BTab previous-window
          bind c new-window -c '#{pane_current_path}'
          bind v split-window -h -c '#{pane_current_path}'
          bind - split-window -v -c '#{pane_current_path}'
          bind z resize-pane -Z

          # Catppuccin Mocha.
          set -g status-position bottom
          set -g status-interval 5
          set -g status-style 'bg=#1e1e2e,fg=#cdd6f4'
          set -g message-style 'bg=#313244,fg=#cdd6f4'
          set -g message-command-style 'bg=#313244,fg=#cdd6f4'
          set -g mode-style 'bg=#f5c2e7,fg=#1e1e2e'
          set -g pane-border-style 'fg=#45475a'
          set -g pane-active-border-style 'fg=#cba6f7'

          set -g status-left-length 40
          set -g status-left '#[bg=#cba6f7,fg=#1e1e2e,bold]  #S  #[bg=#1e1e2e,fg=#cba6f7]'
          set -g window-status-format '#[bg=#1e1e2e,fg=#6c7086] #I:#W '
          set -g window-status-current-format '#[bg=#313244,fg=#cdd6f4,bold] #I:#W '
          set -g window-status-separator ""
          set -g status-right-length 80
          set -g status-right '#[fg=#585b70]#(whoami)@#H  #[fg=#89b4fa]%H:%M #[fg=#a6e3a1]%d %b '
        '';
      };
    };
}
