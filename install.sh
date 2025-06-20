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

unless ENV["CI"]
info "INFO: Installing xcode..."
xcode-select --install
end

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

info "Creating symlinks..."

stow asdf bin direnv gh nvim ssh starship tmux wezterm yabai zsh

info "Install zap..."

zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1

if test ! $(which asdf); then
  mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
  asdf completion zsh >"${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"

  asdf plugin add erlang
  asdf plugin add elixir
  asdf plugin add nodejs
  asdf plugin add pnpm
  asdf plugin add bun
  asdf plugin add postgres
  asdf plugin add direnv
fi
# info "INFO: Cloning personal dotfiles..."
#
# git clone https://github.com/alistairstead/dotfiles2.git ~/dotfiles
#
# cd ~/dotfiles || echo "Cloning dotfiles failed" exit

info "Configuring tmux plugins..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

success "Done!"
