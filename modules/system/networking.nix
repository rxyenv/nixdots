{
  flake.modules.nixos.networking =
    { ... }:

    {
      networking.networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
    }
;
}
