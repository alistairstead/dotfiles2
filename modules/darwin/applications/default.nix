{ config, pkgs, ... }:
{
  imports = [
    ./aerospace
    ./hammerspoon
    ./karabiner
    ./sketchybar
    ./yabai
    ./1password.nix
    ./raycast.nix
  ];
}
