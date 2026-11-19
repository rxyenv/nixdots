{
  flake.modules.homeManager.zsh =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        bzip2
        fastfetch
        less
        micro
        nix-zsh-completions
        unrar
        unzip
        xz
        zstd
      ];

      programs.zsh = {
        enable = true;
        enableCompletion = false; # The reference config initializes compinit.
        envExtra = builtins.readFile ./zsh/zshenv;
        profileExtra = builtins.readFile ./zsh/zprofile;
        initContent =
          builtins.replaceStrings
            [ "@autosuggestions@" "@highlighting@" "@fzf-tab@" ]
            [
              "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
              "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
              "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh"
            ]
            (builtins.readFile ./zsh/zshrc);
      };

      # The reference config initializes these integrations in .zshrc.
      programs.fzf = {
        enable = true;
        enableZshIntegration = false;
      };

      programs.starship = {
        enable = true;
        enableZshIntegration = false;
      };

      programs.zoxide = {
        enable = true;
        enableZshIntegration = false;
      };

      programs.eza.enable = true;

      programs.atuin = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          search_mode = "fuzzy";
          filter_mode = "global";
          style = "compact";
          enter_accept = true;
        };
      };

      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
}
