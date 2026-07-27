{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7b6be2cf-8041-49d4-b615-0d3fa9a457ae";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E609-4187";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  fileSystems."/home/aman/Games" = {
    device = "/dev/disk/by-uuid/9c2c48f6-1790-41a8-a853-943ab117d55a";
    fsType = "btrfs";
    options = [ "defaults" "nofail" ];
  };
}
