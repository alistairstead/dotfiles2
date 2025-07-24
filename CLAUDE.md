# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a GNU Stow-based dotfiles repository for macOS. The repository manages personal configuration files using a modular approach where each application has its own directory containing files that mirror the home directory structure.

## Key Commands

### Installation and Setup

- **Initial installation**: `./install.sh` - Comprehensive installer that sets up entire environment
- **Install Homebrew packages**: `brew bundle`
- **Update all packages**: `brew update && brew upgrade`
- **Link specific app configs**: `stow <app>` (e.g., `stow nvim`)
- **Unlink configs**: `stow -D <app>`
- **Re-stow after changes**: `stow -R <app>`

### Development Commands

- **Karabiner configuration**: 
  - Build: `cd karabiner && pnpm build` (uses tsx to compile TypeScript config)
- **Shell validation**: `shellcheck *.sh scripts/*.sh` (automated via Lefthook pre-commit)
- **Test installation**: Run GitHub Actions workflow (`.github/workflows/test.yml`)

### Tmux Plugin Management

- **Install plugins**: `~/.tmux/plugins/tpm/bin/install_plugins`
- **Update plugins**: `<prefix> + U` (inside tmux)

## Architecture

### Directory Structure

Each application directory follows the Stow convention:
- Files in `app/` get symlinked directly to `~/`
- Files in `app/.config/` get symlinked to `~/.config/app/`
- Special directories like `bin/` contain executable scripts

### Key Configuration Files

- **`install.sh`**: Main installation script that handles:
  - Xcode Command Line Tools installation
  - Homebrew setup and package installation
  - GNU Stow symlink creation
  - Shell configuration (Zsh with Zap plugin manager)
  - Development tools via mise (runtime version manager)
  - macOS system settings
  
- **`Brewfile`**: Declarative package management for Homebrew
  - Core utilities and CLI tools
  - Development tools
  - GUI applications
  - Fonts (Nerd Fonts variants)

- **`.stowrc`**: GNU Stow configuration with ignore patterns

### Application Configurations

- **Shell**: `zsh/` (with Zap plugin manager), `bash/`, `shell/` (common configs)
- **Editor**: `nvim/` - Neovim with LazyVim configuration
- **Terminal**: `ghostty/`, `wezterm/`, `tmux/` (with custom theme and plugins)
- **Window Management**: `aerospace/` (modern tiling), `yabai/` (traditional tiling)
- **Development**: `git/`, `gh/`, `direnv/`, `mise/` (runtime management)
- **Automation**: `karabiner/` - TypeScript-based keyboard customization
- **Claude Integration**: `claude/` - Custom hooks for Claude Code

## Important Notes

1. **Package Management**: Uses Homebrew as primary package manager, mise for runtime versions
2. **Shell**: Zsh is default with Starship prompt and extensive aliases
3. **Theme**: Catppuccin Mocha theme preference across applications
4. **Version Management**: mise handles Node.js, Ruby, Python, etc. (reads .nvmrc, .ruby-version)
5. **Git Hooks**: Lefthook runs shellcheck on pre-commit
6. **CI/CD**: GitHub Actions tests installation on macOS

## When Making Changes

1. **Config Updates**: After modifying configs, run `stow -R <app>` to update symlinks
2. **New Applications**: Create directory structure matching home layout, then `stow <app>`
3. **Brew Packages**: Edit `Brewfile` then run `brew bundle`
4. **Shell Scripts**: Ensure shellcheck compliance (automated via Lefthook)
5. **Karabiner Rules**: Edit TypeScript in `karabiner/src/`, then `pnpm build`

## Claude Code Hooks

The repository includes custom hooks in `claude/.claude/hooks/` that:
- Enforce Bun usage over npm/yarn/pnpm
- Log tool usage for debugging
- Run TypeScript linting
- Send macOS notifications for long-running tasks

## Testing

- **Local Testing**: Run `shellcheck` on shell scripts
- **CI Testing**: GitHub Actions validates installation, syntax, and runs shellcheck
- **Manual Validation**: Check symlinks with `ls -la ~/.config/`