{ config
, lib
, ...
}:
{

  config = lib.mkIf (!config.ci.enable && config.gui.enable && config._1password.enable) {

    home-manager.users.${config.user} = {
      home.sessionVariables = {
        SSH_AUTH_SOCK = "${config.homePath}/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      };
    };

    homebrew = {
      taps = [ "1password/tap" ];

      casks = [
        "1password"
        "1password-cli"
      ];

      masApps = {
        "1Password for Safari" = 1569813296;
      };
    };
  };
}
