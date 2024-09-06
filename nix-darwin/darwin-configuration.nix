{ config, pkgs, ... }:

let
  username =
    let
      envUsername = builtins.getEnv "USERNAME";
    in
    if envUsername == "" then "alistairstead" else envUsername;
in
{

  # Other Nix-Darwin configurations...
}
