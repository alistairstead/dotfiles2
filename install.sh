#!/usr/bin/env sh

echo "Mac OS Install Setup Script"

echo "Cloning personal dotfiles..."

git clone https://github.com/alistairstead/dotfiles2.git ~/dotfiles

cd ~/dotfiles || echo "Cloning dotfiles failed" exit

echo "Installing nix..."
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "nix is installed at version: $(nix --version)"

nix run nix-darwin switch --flake ./nix-darwin

echo "My config files are now managed by nix and home-manager"

ls -la ~/.config

echo "Done!"
