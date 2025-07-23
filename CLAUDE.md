# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix-based dotfiles repository using Nix Flakes for declarative macOS system configuration. The repository manages both system-level (via nix-darwin) and user-level (via home-manager) configurations.

## Key Commands

### System Management

- **Rebuild system**: `rebuild-darwin` (Fish function) or `sudo darwin-rebuild switch --flake .#wombat`
- **Update all packages**: `nix flake update`
- **Check flake**: `nix flake check`
- **Show flake metadata**: `nix flake metadata`

### Development

- **Run repository apps**:
  - `nix run .#readme` - Display documentation
  - `nix run .#rebuild` - Rebuild system
  - `nix run .#help` - Show available options

## Architecture

### Module System

The configuration is organized into modules under `/modules/`:

- **common/**: Cross-platform configurations (applications, programming languages, shell tools)
- **darwin/**: macOS-specific configurations (system settings, Homebrew, window managers)

Each module follows a pattern:

```nix
{ config, lib, pkgs, ... }: {
  options.modules.feature.enable = lib.mkEnableOption "feature";
  config = lib.mkIf config.modules.feature.enable {
    # Configuration here
  };
}
```

### Key Configuration Files

- `flake.nix`: Main entry point, defines system configuration and inputs
- `modules/common/default.nix`: Imports all common modules
- `modules/darwin/default.nix`: Imports all Darwin-specific modules
- Individual feature modules toggle functionality via boolean options in `flake.nix`

### Application Configuration Approach

- Configurations are managed through Nix modules when possible
- Some applications (like Neovim, Tmux) have their configs symlinked or copied
- The repository is transitioning to GNU Stow for managing dotfile symlinks (see `.stowrc`)

## Important Notes

1. **System Hostname**: The system is configured for hostname "wombat" with user "alistairstead"
2. **Theme**: Uses Catppuccin Mocha theme across applications
3. **Shell**: Fish is the default shell with custom functions in `modules/common/shell/fish.nix`
4. **Editor**: Neovim with LazyVim configuration
5. **Window Management**: Uses Yabai (tiling) or Aerospace (alternative) for window management

## When Making Changes

1. **Module Changes**: After modifying any module, run `rebuild-darwin` to apply changes
2. **New Features**: Add enable options in `flake.nix` and create corresponding modules
3. **Testing**: Use `nix flake check` before committing to ensure the configuration is valid
4. **Dependencies**: Add new packages to the appropriate module's `home.packages` or `environment.systemPackages`

## Current Migration

The repository is currently migrating some configurations to use GNU Stow for symlink management. Files are being moved from root directories to `.config/` subdirectories.

