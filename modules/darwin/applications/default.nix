{ ... }:
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
    ./hammerspoon
    ./raycast.nix
  ];
}
