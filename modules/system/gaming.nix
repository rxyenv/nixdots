{ inputs, ... }:
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:

    {
      nixpkgs.overlays = [ inputs.millennium.overlays.default ];

      programs.steam = {
        enable = true;
        package = pkgs.millennium-steam;
        gamescopeSession.enable = true;
        protontricks.enable = true;
      };

      programs.gamescope.enable = true;

      programs.gamemode.enable = true;

      programs.nix-ld.enable = true;

      # GUI control for AMD/NVIDIA GPU + CPU (OC, fan curves, power profiles)
      programs.corectrl.enable = true;

      # Steam controllers, Steam Deck dock, etc.
      hardware.steam-hardware.enable = true;

      # Keep CPU at max frequency — no power saving on a gaming rig
      powerManagement.cpuFreqGovernor = "performance";

      # Spread hardware IRQs across all cores
      services.irqbalance.enable = true;

      boot.kernel.sysctl = {
        "vm.swappiness" = 10;
        "kernel.split_lock_mitigate" = 0;
      };
    };
}
