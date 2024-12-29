{ config
, pkgs
, lib
, ...
}:
{

  config = lib.mkIf pkgs.stdenv.isDarwin {

    home-manager.users.${config.user} = {
      home.sessionVariables = {
        SSH_AUTH_SOCK = "${config.homePath}/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      };
    };
  };
}
