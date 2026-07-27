# nixdots

NixOS configuration for two machines:

| Host | Type | Disks |
|------|------|-------|
| `byte` | Desktop (AMD) | 2× SSD RAID0 + HDD storage |
| `bit` | Laptop (Intel) | Single NVMe |

---

## Fresh install — byte (desktop)

### 1. Boot

Boot the [NixOS minimal ISO](https://nixos.org/download). Connect to the internet:

```bash
# Ethernet — usually works automatically
# Wi-Fi:
sudo systemctl start wpa_supplicant
wpa_cli
> add_network 0
> set_network 0 ssid "SSID"
> set_network 0 psk "PASSWORD"
> enable_network 0
> quit
```

### 2. Identify disks

```bash
lsblk -o NAME,SIZE,MODEL,TYPE
```

Note the device paths for both SSDs and the HDD (e.g. `/dev/nvme0n1`, `/dev/nvme1n1`, `/dev/sda`).

### 3. Clone the repo

```bash
sudo nix-shell -p git
git clone https://github.com/rxyenv/nixdots /tmp/nixdots
cd /tmp/nixdots
```

### 4. Fill in disk devices

Edit `modules/hosts/byte/_disko.nix` and replace the three placeholders:

```bash
nano modules/hosts/byte/_disko.nix
```

| Placeholder | Replace with |
|-------------|--------------|
| `SSD1_DEVICE` | e.g. `/dev/nvme0n1` |
| `SSD2_DEVICE` | e.g. `/dev/nvme1n1` |
| `HDD_DEVICE` | e.g. `/dev/sda` |

### 5. Partition and format with disko

> **Warning:** This wipes all three disks.

```bash
sudo nix run github:nix-community/disko -- \
  --mode disko \
  /tmp/nixdots/modules/hosts/byte/_disko.nix
```

Disko partitions, formats, and mounts everything under `/mnt`.

### 6. Generate hardware configuration

```bash
sudo nixos-generate-config --root /mnt --no-filesystems
```

This creates `/mnt/etc/nixos/hardware-configuration.nix`. Copy it into the repo:

```bash
sudo cp /mnt/etc/nixos/hardware-configuration.nix \
  /tmp/nixdots/modules/hosts/byte/_hardware.nix
```

### 7. Wire disko mounts into the host

The disko module handles all filesystem mounts declaratively, so `_mounts.nix` is no longer needed. Import disko's NixOS module and the disko config in `modules/hosts/byte/default.nix`:

```nix
modules = [
  ./_hardware.nix
  ./_disko.nix                              # add this
  inputs.disko.nixosModules.disko           # add this
  inputs.home-manager.nixosModules.home-manager
  ...
]
```

Remove the `_mounts.nix` import from the same list if present.

### 8. Install

```bash
sudo nixos-install --flake /tmp/nixdots#byte --no-root-passwd
```

This will take a while on first run. When it finishes:

```bash
sudo reboot
```

### 9. Post-install

Log in as root and set the user password:

```bash
passwd aman
```

Log in as `aman`, clone the repo to the expected path, and switch:

```bash
git clone https://github.com/rxyenv/nixdots ~/nixdots
nh os switch ~/nixdots
```

Home-manager activates automatically during the switch. The `i-have-adhd` Claude Code plugin will be installed on first activation if not already present.

---

## Fresh install — bit (laptop)

### 1. Boot and connect

Same as byte step 1.

### 2. Identify the disk

```bash
lsblk -o NAME,SIZE,MODEL,TYPE
```

### 3. Clone the repo

```bash
sudo nix-shell -p git
git clone https://github.com/rxyenv/nixdots /tmp/nixdots
cd /tmp/nixdots
```

### 4. Fill in disk device

Edit `modules/hosts/bit/_disko.nix` and replace `LAPTOP_DISK`:

```bash
nano modules/hosts/bit/_disko.nix
```

e.g. `LAPTOP_DISK` → `/dev/nvme0n1`

### 5. Partition and format

> **Warning:** This wipes the disk.

```bash
sudo nix run github:nix-community/disko -- \
  --mode disko \
  /tmp/nixdots/modules/hosts/bit/_disko.nix
```

### 6. Generate hardware configuration

```bash
sudo nixos-generate-config --root /mnt --no-filesystems
sudo cp /mnt/etc/nixos/hardware-configuration.nix \
  /tmp/nixdots/modules/hosts/bit/_hardware.nix
```

### 7. Wire disko into the host

Import disko in `modules/hosts/bit/default.nix`:

```nix
modules = [
  ./_hardware.nix
  ./_disko.nix                              # add this
  inputs.disko.nixosModules.disko           # add this
  inputs.home-manager.nixosModules.home-manager
  ...
]
```

### 8. Install

```bash
sudo nixos-install --flake /tmp/nixdots#bit --no-root-passwd
sudo reboot
```

### 9. Post-install

```bash
passwd aman           # as root
# then log in as aman:
git clone https://github.com/rxyenv/nixdots ~/nixdots
nh os switch ~/nixdots
```

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

1. Create `modules/hosts/<name>/` with `default.nix`, `_hardware.nix`, `_disko.nix`
2. Follow the same pattern as `byte` or `bit` in `default.nix`
3. The `import-tree` input auto-discovers the new module — no changes to `flake.nix` needed
