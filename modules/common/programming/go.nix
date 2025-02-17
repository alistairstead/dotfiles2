{ config, lib , ...}: {
  options.go.enable = lib.mkEnableOption "Go tools.";

  config = lib.mkIf config.go.enable {

    home-manager.users.${config.user} = {
      home.shellAliases = {
      };

      programs.go = {
        enable = true;
        goPath = "go";
        goBin = "go/bin";
        goPrivate = [ ];
      };
    };
  };
}
