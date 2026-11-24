{
  flake.modules.nixos.networking =
    { ... }:

    {
      services.tailscale.enable = true;

      networking.networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
    }
;
}
