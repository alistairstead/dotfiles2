{ config, pkgs, ... }:
{
  imports = [
    ./aerospace
    ./hammerspoon
    ./karabiner
    ./sketchybar
    ./1password.nix
    ./raycast.nix
  ];
}
