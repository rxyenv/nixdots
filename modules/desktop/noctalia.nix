{ inputs, ... }:

{
  flake.modules.nixos.noctalia =
    { ... }:

    {
      imports = [ inputs.noctalia.nixosModules.default ];

      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };
    }
  ;

  flake.modules.homeManager.noctalia =
    { ... }:

    {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia = {
        enable = true;
        settings = {
          theme.templates.builtin_ids = [ "foot" ];

          # Search these from Super+Space. Commands are global; projects use /project.
          shell.launcher.dmenu.entry = {
            commands = {
              label = "NixOS commands";
              prefix = "cmd";
              global = true;
              command = "printf '%s\\n' 'NixOS check' 'NixOS test byte' 'NixOS switch byte' 'NixOS doctor'";
              exec = "case \"{selection}\" in NixOS\\ check) footclient -e fish -lc 'cd ~/nixdots && nix flake check --no-build; read -P \"Press Enter to close...\"' ;; NixOS\\ test\\ byte) footclient -e fish -lc 'nh os test ~/nixdots#byte; read -P \"Press Enter to close...\"' ;; NixOS\\ switch\\ byte) footclient -e fish -lc 'nh os switch ~/nixdots#byte' ;; NixOS\\ doctor) footclient -e fish -lc 'systemctl --user --failed; read -P \"Press Enter to close...\"' ;; esac";
            };

            projects = {
              label = "Projects";
              prefix = "project";
              command = "for root in \"$HOME/Code\" \"$HOME/Projects\" \"$HOME/src\"; do [ -d \"$root\" ] && find \"$root\" -mindepth 1 -maxdepth 2 -type d -name .git -printf '%h\\n'; done | sort -u";
              exec = "footclient -e fish -lc 'cd -- \"{selection}\"; exec fish'";
            };
          };
        };
      };
    }
  ;
}
