{ config
, pkgs
, lib
, ...
}:
{

  options.node.enable = lib.mkEnableOption "Node tools.";

  config = lib.mkIf config.node.enable {

    home-manager.users.${config.user} = {
      programs.fish.shellAbbrs = {
      };
      home.packages = with pkgs; [
        nodejs
        corepack
      ];
    };
  };
}
