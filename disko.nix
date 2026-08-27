{
  lib,
  primaryDisk ? null,
  secondaryDisk ? null,
  ...
}:

let
  hasPrimary = primaryDisk != null && primaryDisk != "";
  hasSecondary = secondaryDisk != null && secondaryDisk != "";
  secondaryPartition = "/dev/disk/by-partlabel/nixos-secondary";

  btrfsMountOptions = [
    "compress=zstd"
    "noatime"
    "discard=async"
  ];
in
assert lib.assertMsg hasPrimary
  "Pass the primary SSD with --argstr primaryDisk /dev/disk/by-id/<device>.";
assert lib.assertMsg (!hasSecondary || secondaryDisk != primaryDisk)
  "The primary and secondary SSDs must be different devices.";
{
  disko.devices.disk = {
    primary = {
      type = "disk";
      device = primaryDisk;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1MiB";
            size = "1GiB";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };

          btrfs = {
            name = "nixos-primary";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs =
                [
                  "-f"
                  "--label"
                  "nixos"
                ]
                ++ lib.optionals hasSecondary [
                  "--data"
                  "raid0"
                  "--metadata"
                  "raid1"
                  secondaryPartition
                ];

              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = btrfsMountOptions;
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = btrfsMountOptions;
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = btrfsMountOptions;
                };
              };
            };
          };
        };
      };
    };
  }
  // lib.optionalAttrs hasSecondary {
    secondary = {
      type = "disk";
      device = secondaryDisk;
      content = {
        type = "gpt";
        partitions.btrfs = {
          name = "nixos-secondary";
          size = "100%";
        };
      };
    };
  };
}
