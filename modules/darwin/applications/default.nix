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
    ./raycast.nix
  ];
}
