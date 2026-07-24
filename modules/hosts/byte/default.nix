{ config, inputs, ... }:

let
  # Shared nixos modules minus nvidia (byte uses AMD GPU)
  sharedModules = builtins.filter
    (m: m != config.flake.modules.nixos.nvidia)
    (builtins.attrValues config.flake.modules.nixos);
in


{
  flake.nixosConfigurations.byte = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };

    modules = [
      ./hardware.nix
      ./disko.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.disko.nixosModules.disko
      config.flake.modules.nixos.amd

      {
        networking.hostName = "byte";
        system.stateVersion = "26.05";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "bkp";
          extraSpecialArgs = { inherit inputs; };
          users.aman.imports = builtins.attrValues config.flake.modules.homeManager;
        };
      }
    ]
    ++ sharedModules;
  };
}
