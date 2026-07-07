{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    autocd = true;
    enableCompletion = true;
    completionInit = "autoload -Uz compinit && compinit";

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;

      path = "${config.xdg.dataHome}/zsh/history";

      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    shellAliases = {
      c = "clear";
      reload = "source ~/.zshrc";
      please = "sudo";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      conf = "cd ~/.config";
      dots = "cd ~/dotfiles";
      repos = "cd ~/Repos";
      dl = "cd ~/Downloads";

      mkdir = "mkdir -pv";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -I";

      grep = "grep --color=auto";

      vim = "nvim";
      cat = "bat";

      gs = "git status --short";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gpl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      gl = "git log --oneline --graph --decorate --all";

      codex = "codex \"/caveman ultra\"";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      LESS = "-R --use-color -Dd+r -Du+b";
    };

    initContentFirst = ''
      [[ -o interactive ]] && nitch
    '';

    initExtra = ''
      [[ -f "$HOME/.config/zen0x/defaults.sh" ]] && source "$HOME/.config/zen0x/defaults.sh"
      [[ -f "$HOME/.config/zen0x/fzf-theme.zsh" ]] && source "$HOME/.config/zen0x/fzf-theme.zsh"

      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$HOME/.cache/zsh/zcompcache"
      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' fzf-flags \
        --height=40% \
        --layout=reverse \
        --border=rounded \
        --no-preview

      zstyle ':fzf-tab:*' switch-group '<' '>'
      zstyle ':fzf-tab:*' fzf-preview ''

      setopt auto_pushd
      setopt pushd_ignore_dups
      setopt interactive_comments
      setopt no_beep
      setopt prompt_subst
      setopt auto_menu
      setopt auto_list
      setopt complete_in_word
      setopt always_to_end
      setopt glob_dots
      setopt no_nomatch

      bindkey -e

      autoload -Uz up-line-or-beginning-search
      autoload -Uz down-line-or-beginning-search

      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search

      bindkey '^[[A' up-line-or-beginning-search
      bindkey '^[[B' down-line-or-beginning-search

      bindkey '^A' beginning-of-line
      bindkey '^E' end-of-line
      bindkey '^K' kill-line
      bindkey '^U' backward-kill-line
      bindkey '^W' backward-kill-word
      bindkey '^L' clear-screen
      bindkey '^[[3~' delete-char

      if command -v eza >/dev/null; then
        alias l='eza --icons --group-directories-first'
        alias ls='eza --icons --group-directories-first'
        alias ll='eza -lah --icons --group-directories-first --git'
        alias la='eza -A --icons --group-directories-first'
        alias lt='eza --tree --icons --level=2'
      fi

      extract() {
        [[ -f "$1" ]] || {
          echo "File not found: $1"
          return 1
        }

        case "$1" in
          *.tar.bz2) tar xjf "$1" ;;
          *.tar.gz) tar xzf "$1" ;;
          *.tar.xz) tar xJf "$1" ;;
          *.tar.zst) tar --zstd -xf "$1" ;;
          *.tar) tar xf "$1" ;;
          *.tbz2) tar xjf "$1" ;;
          *.tgz) tar xzf "$1" ;;
          *.zip) unzip "$1" ;;
          *.7z) 7z x "$1" ;;
          *.rar) unrar x "$1" ;;
          *.bz2) bunzip2 "$1" ;;
          *.gz) gunzip "$1" ;;
          *.xz) unxz "$1" ;;
          *.zst) unzstd "$1" ;;
          *) echo "Cannot extract: $1" ;;
        esac
      }

      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/.spicetify:$PATH"
    '';

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
      }
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border=rounded"
      "--prompt= "
      "--pointer="
      "--marker="
    ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza.enable = true;
  programs.bat.enable = true;

  home.packages = with pkgs; [
    nitch
    eza
    unzip
    p7zip
    unrar
  ];
}
