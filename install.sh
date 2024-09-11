#!/usr/bin/env bash

set -e

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

#
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

info "INFO: Installing nix..."
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm

. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Run the nix command and capture the output
output=$(nix run "nixpkgs#hello")

# Expected output
expected_output="Hello, world!"

# Check if the output matches the expected output
if [ "$output" = "$expected_output" ]; then
  success "SUCCESS: nix is installed correctly."
  info "INFO: nix is installed at version: $(nix --version)"
else
  error "EXPECTED: '$expected_output'"
  error "GOT: '$output'"
  fail "ERROR: nix is not installed correctly."
fi

# info "INFO: Cloning personal dotfiles..."
#
# git clone https://github.com/alistairstead/dotfiles2.git ~/dotfiles
#
# cd ~/dotfiles || echo "Cloning dotfiles failed" exit

USERNAME="$(whoami)"

info "INFO: Setting up nix-darwin for $USERNAME"
info "INFO: CI = $CI"

export USERNAME

# Move a file that will conflict with nix-darwin
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin

# cd ./nix-darwin || fail "ERROR: can't locate nix-darwin config"
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --impure --show-trace --flake github:alistairstead/dotfiles2#wombat

# echo "My config files are now managed by nix and home-manager"

success "Done!"
