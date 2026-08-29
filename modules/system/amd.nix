{
  flake.modules.nixos.amd =
    { pkgs, ... }:

    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = [ pkgs.mesa.opencl ];
      };

      # OpenCL compute backend used by DaVinci Resolve on AMD GPUs.
      environment.sessionVariables.RUSTICL_ENABLE = "radeonsi";

      boot.initrd.kernelModules = [ "amdgpu" ];

      services.xserver.videoDrivers = [ "amdgpu" ];
    };
}
