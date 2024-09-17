{ config
, lib
, ...
}:
{
  options = {
    aerospace = {
      enable = lib.mkEnableOption {
        description = "Enable Aerospace.";
        default = false;
      };
    };
  };

  config = lib.mkIf (!config.ci.enable && config.gui.enable && config.aerospace.enable) {
    homebrew = {
      taps = [
        "nikitabobko/tap"
      ];
      casks = [
        "aerospace"
      ];
    };

    home-manager.users.${config.user} = {
      xdg.configFile."aerospace/aerospace.toml".source = ./aerospace.toml;
    };
  };
}
