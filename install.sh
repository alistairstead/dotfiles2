#!/usr/bin/env sh

echo "Mac OS Install Setup Script"

sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

echo "Installing personal dotfiles..."

git clone https://github.com/alistairstead/dotfiles2.git ~/dotfiles

cd ~/dotfiles || echo "Cloning dotfiles failed" exit

echo "Installing nix..."
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

which nix

nix --version

nix run nix-darwin nix-command flakes -- switch --flake ./nix-darwin

echo "Done!"
