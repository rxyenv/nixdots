{
  flake.modules.nixos.xserver =
    { lib, ... }:

    {
      services.displayManager.ly = {
        enable = true;
        settings.tty = lib.mkForce 2;
      };
    }
;
}
