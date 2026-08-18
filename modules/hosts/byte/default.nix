{ config, inputs, ... }:

{
  flake.nixosConfigurations.byte = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };

    modules = [
      ./_hardware.nix
      inputs.home-manager.nixosModules.home-manager

      ({ pkgs, ... }: {
        hardware.graphics.extraPackages = with pkgs; [
          libvdpau-va-gl
        ];

        hardware.i2c.enable = true;
        hardware.amdgpu.overdrive.enable = true;

        boot.kernelParams = [
          "acpi_enforce_resources=lax"
          "amdgpu.ppfeaturemask=0xffffffff"
        ];

        environment.systemPackages = with pkgs; [ openrgb ];
      })

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
