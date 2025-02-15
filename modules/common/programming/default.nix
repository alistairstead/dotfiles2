{ config, pkgs, ... }: {
  imports = [
    ./aws.nix
    ./devenv.nix
    ./go.nix
    ./node.nix
    ./php
    ./terraform.nix
  ];

  config = {
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [
        lazydocker
        lazygit
        lazysql
        prettierd
      ];
    };
  };

}
