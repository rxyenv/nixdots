{
  flake.modules.nixos.security =
    { ... }:

    {
      security.polkit.enable = true;

security.pam.services.ly.enableGnomeKeyring = true;

      programs.dconf.enable = true;

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    }
;
}
