{ config, pkgs, ... }:
{
  config =
    {
      unfreePackages = [
        "raycast"
      ];
    };

  imports = [
    ./1password.nix
    ./aerospace
    # ./hammerspoon
    ./karabiner
    ./raycast.nix
  ];
}
