# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a GNU Stow-based dotfiles repository for macOS. The repository manages personal configuration files using a modular approach where each application has its own directory containing files that mirror the home directory structure.

## Key Commands

### Installation and Setup

- **Initial installation**: `./install.sh` - Comprehensive installer that sets up entire environment
- **Install Homebrew packages**: `brew bundle`
- **Update all packages**: `brew update && brew upgrade`
- **Link specific app configs**: `stow <app>` (e.g., `stow zsh`)
- **Unlink configs**: `stow -D <app>`
- **Re-stow after changes**: `stow -R <app>`

### Development Commands

- **Karabiner configuration**: 
  - Build: `cd karabiner && pnpm build` (uses tsx to compile TypeScript config)
- **Shell validation**: `shellcheck *.sh scripts/*.sh` (also enforced in CI)
- **Test installation**: Run GitHub Actions workflow (`.github/workflows/test.yml`)

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

- **Shell**: `zsh/` (Homebrew plugins, zsh-abbr), `bash/`, `shell/` (common configs shared by both)
- **History**: `atuin/` - shell history in SQLite. Owns `Ctrl+R` and the up arrow; `atuin init` is sourced late in `.zshrc` (after the fzf key bindings and after `bindkey -v`, both of which would otherwise clobber it), while `atuin pty-proxy init` must be the *first* line of `.zshrc` because it re-execs the shell. `[dotfiles]` is deliberately disabled — aliases and env vars stay in `shell/`, see the config's own comments. `permissions.ai.toml` gates what the `?` assistant may read, write and run
- **Editor**: `zed/` - Zed settings, keymap, tasks
- **Terminal**: `ghostty/`
- **Window Management**: `yabai/` (tiling window manager)
- **Development**: `git/`, `gh/`, `direnv/` (`direnvrc` carries `use_aws` / `use_gcloud` for per-project cloud context, see `direnv/README.md`), `mise/` (runtime management)
- **Automation**: `karabiner/` - TypeScript-based keyboard customization
- **Claude Integration**: `claude/` - Custom hooks for Claude Code

## Important Notes

1. **Package Management**: Uses Homebrew as primary package manager, mise for runtime versions
2. **Shell**: Zsh is default with Starship prompt and extensive aliases
3. **Theme**: Catppuccin Mocha theme preference across applications
4. **Version Management**: mise handles Node.js, Ruby, Python, etc. (reads .nvmrc, .ruby-version)
5. **CI/CD**: GitHub Actions tests installation on macOS

## When Making Changes

1. **Config Updates**: After modifying configs, run `stow -R <app>` to update symlinks
2. **New Applications**: Create directory structure matching home layout, then `stow <app>`. The installer picks it up automatically: `scripts/stow-modules.sh` derives the package list from the directories on disk, and CI checks every tracked file in every package landed in `$HOME`. Add an exclusion there only if the directory is not a `$HOME` mirror (as with `karabiner/`).
3. **Brew Packages**: Edit `Brewfile` then run `brew bundle`
4. **Shell Scripts**: Ensure shellcheck compliance (enforced in CI)
5. **Karabiner Rules**: Edit TypeScript in `karabiner/src/`, then `pnpm build`

## Claude Code Hooks

The repository includes custom hooks in `claude/.claude/hooks/` that:
- Enforce Bun usage over npm/yarn/pnpm, and log tool usage (`pre-use-tool.ts`)
- Send macOS notifications for long-running tasks
- Speak events aloud via Piper TTS, falling back to `say`; voice tuning in `VOICE_PROFILES` in `claude/.claude/hooks/speak-notification.ts` (see hooks README)

## Testing

- **Local Testing**: Run `shellcheck` on shell scripts
- **CI Testing**: GitHub Actions validates installation, syntax, and runs shellcheck
- **Manual Validation**: Check symlinks with `ls -la ~/.config/`