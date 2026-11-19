{
  flake.modules.nixos.users =
    { pkgs, ... }:

    {
      programs.zsh.enable = true;

      users.defaultUserShell = pkgs.zsh;

      users.users.aman = {
        isNormalUser = true;
        description = "Aman K M";

        shell = pkgs.zsh;

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
