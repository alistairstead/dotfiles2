#!/usr/bin/env sh

sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

echo "Mac OS Install Setup Script"

echo "Cloning personal dotfiles..."

git clone https://github.com/alistairstead/dotfiles2.git ~/dotfiles

cd ~/dotfiles || echo "Cloning dotfiles failed" exit

echo "Installing nix..."
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

# Move a file that will conflict with nix-darwin
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin

cd ./nix-darwin || echo "ERROR: can't locate nix-darwin config" exit
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .#simple

# echo "My config files are now managed by nix and home-manager"

ls -la ~/.config

echo "Done!"
