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
      programs = {
        # shell integrations are enabled by default
        lazygit.enable = true; # git tui
      };

      home.packages = with pkgs; [
        diff-so-fancy
        lazydocker
        lazysql
        prettierd
      ];
    };
  };

}
