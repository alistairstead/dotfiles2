{ config, pkgs , lib , ...}: {
  options.go.enable = lib.mkEnableOption "Go tools.";

  config = lib.mkIf config.go.enable {

    home-manager.users.${config.user} = {
      home.shellAliases = {
      };
      home.packages = with pkgs; [
        go
      ];
    };
  };
}
