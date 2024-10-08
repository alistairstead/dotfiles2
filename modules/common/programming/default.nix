{ config, pkgs, ... }:
{

  imports = [
    ./aws.nix
    ./devenv.nix
    ./go.nix
    ./node.nix
    ./terraform.nix
  ];

  config = {
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [
        prettierd
      ];
    };
  };

}
