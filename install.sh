echo "Installing personal dotfiles..."
git clone git@github.com:alistairstead/dotfiles2.git ~/dotfiles

cd ~/dotfiles || exit

echo "Installing nix..."
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

which nix

nix --version

nix run nix-darwin nix-command flakes -- switch --flake ./nix-darwin

echo "Done!"
