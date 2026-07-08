{ ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  # let rustup-downloaded toolchains (dynamically linked) find system libs
  programs.nix-ld.enable = true;
}
