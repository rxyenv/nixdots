{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting

      if status is-interactive
        fastfetch
      end
    '';

    shellAliases = {
      ls = "eza";
      ll = "eza -l --header";
      la = "eza -la --header";
      lt = "eza --tree --level=2";
      lta = "eza --tree --level=3 -a";
      cat = "bat";
    };

    shellAbbrs = {
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      hms = "home-manager switch --flake ~/nixdots";
      nfc = "nix flake check --no-build";
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "fzf.fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        # cleans stale history entries (typos, failed commands) on the fly
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
      {
        # desktop notification when a long-running command finishes in an unfocused terminal
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "colored-man-pages";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }
      {
        # git aliases matching common oh-my-zsh muscle memory, complements shellAbbrs above
        name = "forgit";
        src = pkgs.fishPlugins.forgit.src;
      }
    ];
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "auto";
    git = true;
    colors = "auto";
    extraOptions = [
      "--group-directories-first"
      "--time-style=long-iso"
    ];
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };
}
