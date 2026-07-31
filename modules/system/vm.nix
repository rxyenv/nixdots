{
  flake.modules.nixos.vm =
    { pkgs, ... }:

    {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          ovmf.enable = true;
          swtpm.enable = true;
        };
      };

      programs.virt-manager.enable = true;

      users.users.aman.extraGroups = [ "libvirtd" ];

      environment.systemPackages = with pkgs; [
        virt-viewer
      ];
    };
}
