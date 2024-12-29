{ config
, lib
, ...
}:
{

  options = {
    ghostty = {
      enable = lib.mkEnableOption {
        description = "Enable Ghostty terminal.";
        default = false;
      };
    };
  };

  config =
    lib.mkIf (!config.ci.enable && config.gui.enable && config.ghostty.enable) {


      home-manager.users.${config.user} = {

        xdg.configFile."ghostty/config".source = ./config;
      };
    };
}
