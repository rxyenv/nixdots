{
  flake.modules.nixos.xserver =
    { ... }:

    {
      services.displayManager.ly.enable = true;
    }
;
}
