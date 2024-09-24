{ config
, pkgs
, lib
, ...
}:
{

  options.go.enable = lib.mkEnableOption "Go tools.";

  config = lib.mkIf config.go.enable {

    home-manager.users.${config.user} = {
      programs.fish.shellAbbrs = {
      };
      home.packages = with pkgs; [
        go
      ];
    };
  };
}
