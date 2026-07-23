{
  flake.modules.homeManager.gtk =
    { pkgs, inputs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      abyssal = inputs.abyssal-gtk-theme.packages.${system}.default;
    in
    {
      # Theme/icon packages only; settings.ini and gtk-4.0/gtk.css are
      # written by the zen0x theme engine so switching needs no rebuild
      home.packages = [
        abyssal
        pkgs.yaru-theme
      ];
    }
;
}
