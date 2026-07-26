{ config, inputs, ... }:

{
  flake.nixosConfigurations.byte = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };

    modules = [
      ./_hardware.nix
      ./_mounts.nix
      inputs.home-manager.nixosModules.home-manager

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
    ++ builtins.attrValues (builtins.removeAttrs config.flake.modules.nixos [ "nvidia" ]);
  };
}
