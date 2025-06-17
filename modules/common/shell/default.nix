{ pkgs, lib, config, ... }: {
  imports = [
    # ./fish
    # ./charm.nix
    # ./editorconfig.nix
    # ./eza.nix
    # ./git.nix
    # ./github.nix
    ./nixpkgs.nix
    # ./starship.nix
    # ./zoxide.nix
  ];
  config = {
    home-manager.users.${config.user} = { pkgs, lib, ... }: {
      programs = {
        home-manager.enable = true;
      };
    };
  };
}
