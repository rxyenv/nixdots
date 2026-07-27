{ ... }:

# byte (desktop) — 2 SSDs in btrfs RAID0 + HDD for storage
#
# Replace placeholders before running disko:
#   SSD1_DEVICE  e.g. /dev/nvme0n1
#   SSD2_DEVICE  e.g. /dev/nvme1n1
#   HDD_DEVICE   e.g. /dev/sda
#
# Run with:
#   nix run github:nix-community/disko -- --mode disko /path/to/_disko.nix

{
  disko.devices = {
    disk = {
      ssd1 = {
        type = "disk";
        device = "SSD1_DEVICE";
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
                name = "pool";
                # RAID0: stripe both data and metadata across both SSDs.
                # No redundancy — one drive failure = total loss.
                extraArgs = [ "-d" "raid0" "-m" "raid0" "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };

      ssd2 = {
        type = "disk";
        device = "SSD2_DEVICE";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                name = "pool"; # joins the same btrfs pool as ssd1
              };
            };
          };
        };
      };

      hdd = {
        type = "disk";
        device = "HDD_DEVICE";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/storage";
                mountOptions = [ "defaults" "nofail" ];
              };
            };
          };
        };
      };
    };
  };
}
