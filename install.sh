#!/usr/bin/env sh

sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

echo "INFO: Mac OS Install Setup Script"

unless ENV["CI"]
echo "INFO: Installing xcode..."
xcode-select --install
end

#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if test ! "$(which brew)"; then
  echo "INFO: Installing Homebrew for you."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew upgrade
brew update

echo "INFO: Installing nix..."
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm

. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Run the nix command and capture the output
output=$(nix run "nixpkgs#hello")

# Expected output
expected_output="Hello, world!"

# Check if the output matches the expected output
if [ "$output" = "$expected_output" ]; then
  echo "SUCCESS: nix is installed correctly."
  echo "INFO: nix is installed at version: $(nix --version)"
else
  echo "ERROR: nix is not installed correctly."
  echo "EXPECTED: '$expected_output'"
  echo "GOT: '$output'"
  exit 1
fi

echo "INFO: Cloning personal dotfiles..."

git clone https://github.com/alistairstead/dotfiles2.git ~/dotfiles

cd ~/dotfiles || echo "Cloning dotfiles failed" exit

USERNAME="$(whoami)"

echo "INFO: Setting up nix-darwin for $USERNAME"

export USERNAME

# Move a file that will conflict with nix-darwin
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin

cd ./nix-darwin || echo "ERROR: can't locate nix-darwin config" exit
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .#simple

# echo "My config files are now managed by nix and home-manager"

ls -la ~/.config

echo "CI: $CI"

echo "Done!"
