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
- **Window Management**: Aerospace, Yabai
- **Version Management**: mise (fast runtime manager, reads .nvmrc, .ruby-version, etc.)
- **Development Tools**: Git, GitHub CLI, Direnv

### Key Features

- Touch ID for sudo authentication
- Catppuccin Mocha theme across applications
- Declarative package management via Brewfile
- Modular configuration with GNU Stow

## First run

`install.sh` handles everything a script can. The rest needs a human: signing
into 1Password so git can sign commits, granting yabai and Karabiner their
macOS permissions, signing into the App Store. A wizard walks through those
step by step, in order, and tells you what it could not finish:

```bash
./scripts/first-run.sh
```

Safe to re-run; it detects what is already done.

## Manual Setup

If you prefer to set up components individually:

```bash
# Install Homebrew packages
brew bundle

# Configure macOS settings
./scripts/macos-setup.sh

# Link dotfiles
stow git zsh # etc...
```

## Directory Structure

Each directory contains configuration for a specific application:

- `app/` - Contains files that will be symlinked to home directory
- `app/.config/` - Contains files for `~/.config/app/`

## Customization

1. Edit `Brewfile` to add/remove packages
2. Modify application configs in their respective directories
3. Run `stow <app>` to update symlinks after changes

## Cloud CLI Setup

Sync AWS SSO profiles into `~/.aws/config`:

```bash
granted-refresh
```

Then assume a role with `assume <profile>`, and clear it with `unassume`.

Cloud context is scoped per project by direnv rather than left sticky in the
shell, so the prompt only advertises the cloud a project actually uses:

```sh
use aws kodehort eu-west-2                  # .envrc in an AWS project
use gcloud default genie-goals-analytics    # .envrc in a GCP project
```

See [direnv/README.md](direnv/README.md) for the full behaviour, and
[SHELL_FUNCTIONS.md](SHELL_FUNCTIONS.md#cloud-context-direnv) for the alias list.

## Troubleshooting

- If symlinks fail, check for existing files in target locations
- Run `stow -D <app>` to remove symlinks before re-stowing
- For Touch ID issues, check `/etc/pam.d/sudo_local`
