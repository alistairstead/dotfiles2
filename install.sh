curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

which nix

nix --version

nix run nix-darwin --experimental-feature nix-command --experimental-feature flakes -- switch --flake ./nix-darwin
