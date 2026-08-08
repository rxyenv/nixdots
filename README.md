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
sudo nix-shell -p git
git clone git@github.com:rxyenv/nixdots.git /tmp/nixdots
cd /tmp/nixdots
```

### 3. Partition and mount

Partition and format the disks manually, then mount them under `/mnt`. The checked-in `_hardware.nix` matches each host's layout, so generate a fresh one if needed:

```bash
sudo nixos-generate-config --root /mnt --no-filesystems
sudo cp /mnt/etc/nixos/hardware-configuration.nix modules/hosts/<host>/_hardware.nix
```

### 4. Install

```bash
sudo nixos-install --flake /tmp/nixdots#<host> --no-root-passwd
sudo reboot
```

### 5. Post-install

Log in as root and set the user password:

```bash
passwd aman
```

Then log in as `aman`, clone the repo to the expected path, and switch:

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
