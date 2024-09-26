{ ... }:
{
  config =
    {
      unfreePackages = [
        "raycast"
      ];
    };

  imports = [
    ./aerospace
    ./hammerspoon
    ./raycast.nix
  ];
}
