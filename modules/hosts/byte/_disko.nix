{ ... }:

# byte (desktop) — 2x 1TB SSD (btrfs RAID-0) + 1x 2TB HDD (/data)
# Replace:
#   SSD1 → /dev/nvme0n1 (or sda)
#   SSD2 → /dev/nvme1n1 (or sdb)
#   HDD  → /dev/sda     (or sdc)
{
  disko.devices.disk = {
    ssd1 = {
      device = "SSD1";
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
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              # data: RAID-0 (full 2TB, no redundancy)
              # metadata: RAID-1 (survives one SSD failure)
              extraArgs = [ "-d" "raid0" "-m" "raid1" "--label" "nixos" "-f" "SSD2_PARTITION" ];
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

    ssd2 = {
      device = "SSD2";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              existingPool = "nixos";
            };
          };
        };
      };
    };

    hdd = {
      device = "HDD";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          data = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/data";
              mountOptions = [ "noatime" "lazytime" ];
            };
          };
        };
      };
    };
  };
}
