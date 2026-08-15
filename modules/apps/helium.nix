{
  flake.modules.homeManager.helium =
    { pkgs, inputs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      helium = inputs.helium-browser.packages.${system}.default;
      helium-no-csd = helium.overrideAttrs (old: {
        installPhase = old.installPhase + ''
          substituteInPlace "$out/bin/helium" \
            --replace-fail \
              "--enable-features=WaylandWindowDecorations" \
              "--disable-features=WaylandWindowDecorations"
        '';
      });
    in
    {
      home.packages = [ helium-no-csd ];
      home.sessionVariables.BROWSER = "helium";
    };
}
