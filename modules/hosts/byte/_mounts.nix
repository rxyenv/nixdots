{
  fileSystems."/home/aman/Storage" = {
    device = "/dev/disk/by-label/Storage";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  fileSystems."/home/aman/Games" = {
    device = "/dev/disk/by-uuid/9c2c48f6-1790-41a8-a853-943ab117d55a";
    fsType = "btrfs";
    options = [ "defaults" "nofail" ];
  };
}
