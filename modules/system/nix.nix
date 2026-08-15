{
  flake.modules.nixos.nix =
    { pkgs, config, ... }:

    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix.settings.auto-optimise-store = true;
      nix.settings.max-jobs = "auto";
      nix.settings.cores = 16;

      nix.settings.substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      nix.settings.trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      nix.gc = {
        automatic = false;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      nixpkgs.config.allowUnfree = true;

      programs.nh = {
        enable = true;
        flake = "${config.users.users.aman.home}/nixdots";
        clean.enable = true;
      };

      # let rustup-downloaded toolchains (dynamically linked) find system libs
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc.lib
          zlib
          openssl
          curl
          libgcc
        ];
      };

      environment.systemPackages = with pkgs; [
        nix-output-monitor
        nix-search-cli
      ];
    }
;
}
