curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

nix run nix-darwin --experimental-feature nix-command --experimental-feature flakes -- switch --flake ./nix-darwin
