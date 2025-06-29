# dotfiles

Personal macOS configuration files managed with GNU Stow.

## Quick Start

```bash
git clone https://github.com/alistairstead/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

[![Test Installation](https://github.com/alistairstead/dotfiles/actions/workflows/test.yml/badge.svg)](https://github.com/alistairstead/dotfiles/actions/workflows/test.yml)

## What's Included

### Applications

- **Terminal**: Ghostty, WezTerm
- **Editor**: Neovim (LazyVim configuration)
- **Shell**: Zsh with Starship prompt
- **Multiplexer**: Tmux
- **Window Management**: Aerospace, Yabai
- **Version Management**: mise (fast runtime manager, reads .nvmrc, .ruby-version, etc.)
- **Development Tools**: Git, GitHub CLI, Direnv

### Key Features

- Touch ID for sudo authentication
- Catppuccin Mocha theme across applications
- Declarative package management via Brewfile
- Modular configuration with GNU Stow

## Manual Setup

If you prefer to set up components individually:

```bash
# Install Homebrew packages
brew bundle

# Configure macOS settings
./scripts/macos-setup.sh

# Link dotfiles
stow git nvim tmux zsh # etc...

# Install tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins
```

## Directory Structure

Each directory contains configuration for a specific application:

- `app/` - Contains files that will be symlinked to home directory
- `app/.config/` - Contains files for `~/.config/app/`

## Customization

1. Edit `Brewfile` to add/remove packages
2. Modify application configs in their respective directories
3. Run `stow <app>` to update symlinks after changes

## AWS CLI Setup

Sync settings for AWS CLI:

```bash
granted-refresh
```

## Troubleshooting

- If symlinks fail, check for existing files in target locations
- Run `stow -D <app>` to remove symlinks before re-stowing
- For Touch ID issues, check `/etc/pam.d/sudo_local`
