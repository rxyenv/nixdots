{
  flake.modules.nixos.fonts =
    { pkgs, ... }:

    {
      fonts.packages = (with pkgs.nerd-fonts; [
        jetbrains-mono
        droid-sans-mono
      ]) ++ (with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        maple-mono.NF
        google-fonts
        monocraft
      ]);

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [ "JetBrainsMono Nerd Font Mono" ];
          sansSerif = [ "Droid Sans Mono Nerd Font" "Noto Sans Telugu" ];
          serif = [ "Droid Sans Mono Nerd Font" "Noto Serif Telugu" ];
        };
      };
    }
;
}
