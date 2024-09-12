{ ... }:
{
  config =
    {
      unfreePackages = [
        "raycast"
      ];
    };

  imports = [
    ./raycast.nix
  ];
}
