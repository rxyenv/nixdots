{
  flake.modules.homeManager.zed =
    { pkgs, inputs, ... }:
    let
      abyssal-zed-themes = pkgs.stdenvNoCC.mkDerivation {
        pname = "abyssal-zed-themes";
        version = "unstable";
        src = inputs.abyssal-zed-themes;
        installPhase = ''
          mkdir -p $out/share/zed/themes
          cp abyssal/*.json $out/share/zed/themes/
        '';
      };
    in
    {
      # recursive: link each theme file so manually added themes can coexist
      xdg.configFile."zed/themes" = {
        source = "${abyssal-zed-themes}/share/zed/themes";
        recursive = true;
      };
    };
}
