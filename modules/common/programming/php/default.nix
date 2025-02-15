{ config, lib , ... }: {
  options.php.enable = lib.mkEnableOption "PHP tools.";
  config = lib.mkIf config.php.enable {
    home-manager.users.${config.user} = {
      home.sessionPath = [ "$HOME/.config/bin" ];

      xdg.configFile."bin/dphpunit".source = ./dphpunit;
    };
  };
}
