{ config
, lib
, pkgs
, ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
in
{
  options.aws.enable = lib.mkEnableOption "AWS tools.";

  config = lib.mkIf config.aws.enable {
    environment.systemPackages = with pkgs; [
      granted
    ];

    home-manager.users.${config.user} = {
      home.sessionVariables = {
        GRANTED_ALIAS_CONFIGURED = "true";
        GRANTED_ENABLE_AUTO_REASSUME = "true";
      };

      programs.awscli = {
        enable = true;
      };

      programs.fish = {
        shellAliases = {
          assume = lib.mkIf isDarwin "source ${pkgs.granted}/share/assume.fish";
          granted-refresh = lib.mkIf isDarwin "granted sso populate --sso-region eu-west-2 https://kodehort.awsapps.com/start";
        };

        interactiveShellInit = ''
          set -x AWS_SDK_LOAD_CONFIG 1
        '';
      };
    };
  };
}
