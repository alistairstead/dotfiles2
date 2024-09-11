# Hosts

These are the individual machines managed by this flake.

| Host                           | Purpose |
| ------------------------------ | ------- |
| [wmobat](./wombat/default.nix) | MacBook |

## NixOS Workflow

Each hosts file is imported into [nixosConfigurations](../flake.nix) and passed
the arguments from the flake (inputs, globals, overlays). The `nixosSystem`
function in that hosts file will be called by the NixOS module system during a
nixos-rebuild.

Each module in the each host's `modules` list is either a function or an
attrset. The attrsets will simply apply values to options that have been
declared in the config by other modules. Meanwhile, the functions will be
passed various arguments, several of which you will see listed at the top of
each of their files.
