{ ... }: {
  imports = [
    ./homebrew.nix
    ./shell
    ./system.nix
    ./user.nix
  ];
}
