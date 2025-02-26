{ config, pkgs, ... }:
{
  imports = [
    ./aerospace
    ./hammerspoon
    ./karabiner
    ./yabai
    ./1password.nix
    ./raycast.nix
  ];
}
