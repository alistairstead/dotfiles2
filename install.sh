#!/usr/bin/env bash

## Helper functions

info() {
  # shellcheck disable=SC2059
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

success() {
  # shellcheck disable=SC2059
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

error() {
  # shellcheck disable=SC2059
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
}

fail() {
  # shellcheck disable=SC2059
  error "$1"
  exit 1
}

## Run script as sudo if not already

sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

info "INFO: Mac OS System Install Setup Script"

# Install Xcode command line tools if not in CI environment
if [ -z "$CI" ]; then
  info "INFO: Installing xcode command line tools..."
  xcode-select --install 2>/dev/null || true
fi

# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if test ! "$(which brew)"; then
  info "INFO: Installing Homebrew for you."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew upgrade
brew update

info "Installing packages from Brewfile..."
brew bundle

info "Creating symlinks..."

stow bin direnv gh git mise nvim ssh starship tmux wezterm yabai zsh

info "Install zap..."

zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1

info "Setting up mise for runtime management..."

if test ! $(which mise); then
  info "Installing mise..."
  brew install mise
fi

# Install common development tools with mise
info "Installing development runtimes with mise..."

# Install Node.js LTS
mise use --global node@lts

# Install other common tools
mise use --global python@latest
mise use --global ruby@latest
mise use --global go@latest

# Install package managers
mise use --global pnpm@latest
mise use --global bun@latest

# For any existing .tool-versions files, mise will automatically read them
info "Mise is configured to read .nvmrc, .ruby-version, .tool-versions, etc."
# info "INFO: Cloning personal dotfiles..."
#
# git clone https://github.com/alistairstead/dotfiles2.git ~/dotfiles
#
# cd ~/dotfiles || echo "Cloning dotfiles failed" exit

info "Configuring tmux plugins..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

success "Done!"

info "Note: mise is now configured as your runtime manager."
info "It will automatically read .nvmrc, .ruby-version, .tool-versions, etc."
info "Run 'mise doctor' to verify the installation."
info "See MISE_MIGRATION.md for migration guide from asdf."
