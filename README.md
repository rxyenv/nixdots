# nixdots

NixOS configuration for two machines:

| Host | Type |
|------|------|
| `byte` | Desktop (AMD) |
| `bit` | Laptop (Intel) |

Built with [flake-parts](https://flake.parts) and [import-tree](https://github.com/vic/import-tree). Host configs live in `modules/hosts/<name>/`; new hosts are auto-discovered, no `flake.nix` edits needed.

---

## Fresh install

### 1. Boot

Boot the [NixOS minimal ISO](https://nixos.org/download) and connect to the internet.

### 2. Clone the repo

```bash
sudo -i
nix-shell -p git
git clone https://github.com/rxyenv/nixdots.git /tmp/nixdots
cd /tmp/nixdots
```

### 3. Identify the SSDs

List the disks and their stable device paths:

```bash
lsblk -d -o NAME,SIZE,MODEL,SERIAL
ls -l /dev/disk/by-id/
```

Use paths such as `/dev/disk/by-id/nvme-Samsung_SSD_...`. Do not select a
partition path ending in `-part1`.

### 4. Partition and mount

The primary SSD is formatted as Btrfs. If a secondary SSD is provided, it is
added to the filesystem with RAID0 data and RAID1 metadata. Press Enter at the
secondary prompt to use only the primary SSD.

> **Warning:** this destroys all data on the selected SSDs.

```bash
lsblk -d -o NAME,SIZE,MODEL,SERIAL

read -rp "Primary SSD (/dev/disk/by-id/...): " primary_ssd
read -rp "Secondary SSD (optional, Enter to skip): " secondary_ssd

disko_args=(--mode destroy,format,mount --argstr primaryDisk "$primary_ssd")
if [[ -n "$secondary_ssd" ]]; then
  disko_args+=(--argstr secondaryDisk "$secondary_ssd")
fi

sudo nix run github:nix-community/disko/latest -- \
  "${disko_args[@]}" ./disko.nix
```

Confirm that Disko mounted the new filesystem:

```bash
findmnt --target /mnt
findmnt --target /mnt/boot
findmnt --target /mnt/home
findmnt --target /mnt/nix
```

### 5. Generate the hardware configuration

Select the machine being installed:

```bash
# Desktop (AMD)
host=byte

# Laptop (Intel), use this instead:
# host=bit
```

Generate its hardware configuration:

```bash
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  "modules/hosts/$host/_hardware.nix"
```

### 6. Install

```bash
nixos-install --flake "/tmp/nixdots#$host" --no-root-passwd
```

Set the `aman` user password inside the installed system, then reboot:

```bash
nixos-enter --root /mnt -c 'passwd aman'
reboot
```

Remove the live ISO when the machine restarts.

> **RAID0 warning:** with two SSDs, losing either SSD loses the entire Btrfs
> filesystem. RAID0 increases usable capacity and performance but provides no
> data redundancy.

### 7. Post-install

Log in as `aman`, clone the repo to the expected path, and switch:

```bash
git clone git@github.com:rxyenv/nixdots.git ~/nixdots
nh os switch ~/nixdots
```

Home-manager activates automatically during the switch.

---

## Day-to-day usage

```bash
# Rebuild and switch
nh os switch ~/nixdots

# Home-manager only
nh home switch ~/nixdots

# Update all flake inputs
nix flake update ~/nixdots

# Garbage collect (auto-managed, but manual trigger):
nix-collect-garbage -d
```

---

## Adding a new host

1. Create `modules/hosts/<name>/` with `default.nix` and `_hardware.nix`
2. Follow the same pattern as `byte` or `bit` in `default.nix`
3. The `import-tree` input auto-discovers the new module — no changes to `flake.nix` needed
