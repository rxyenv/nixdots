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
        settings.theme.templates.builtin_ids = [ "foot" ];
      };
    }
  ;
}
