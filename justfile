set shell := ["bash", "-euo", "pipefail", "-c"]

default: check

# Check evaluation without building or switching the system.
check:
    nix flake check --no-build

# Format the complete flake using the formatter declared by the flake.
fmt:
    nix fmt

# Build a host configuration without activating it.
test host="byte":
    nh os test "{{invocation_directory()}}#{{host}}"

# Activate a host configuration.
switch host="byte":
    nh os switch "{{invocation_directory()}}#{{host}}"

# Inspect the live graphical session for expected runtime components.
doctor:
    systemctl --user --failed

# Boot the previous NixOS generation.
rollback:
    sudo nixos-rebuild switch --rollback
