{
  flake.modules.nixos.users =
    { pkgs, ... }:

    {
      programs.fish.enable = true;

      users.defaultUserShell = pkgs.fish;

      users.users.aman = {
        isNormalUser = true;
        description = "Aman K M";

        shell = pkgs.fish;

        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "input"
          "audio"
          "i2c"
        ];
      };
    }
;
}
