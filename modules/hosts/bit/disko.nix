{ ... }:

# bit (laptop) — single drive
# Replace LAPTOP_DISK with actual device e.g. /dev/nvme0n1
{
  disko.devices.disk.main = {
    device = "LAPTOP_DISK";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };
        swap = {
          size = "16G";
          content = {
            type = "swap";
            discardPolicy = "both";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/root" = { mountpoint = "/";     mountOptions = [ "compress=zstd" "noatime" ]; };
              "/home" = { mountpoint = "/home"; mountOptions = [ "compress=zstd" "noatime" ]; };
              "/nix"  = { mountpoint = "/nix";  mountOptions = [ "compress=zstd" "noatime" ]; };
            };
          };
        };
      };
    };
  };
}
