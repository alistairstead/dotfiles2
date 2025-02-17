{ config, lib , pkgs , ...}:
let
  inherit (pkgs.stdenv) isDarwin;
in
{
  options.aws.enable = lib.mkEnableOption "AWS tools.";

  config = lib.mkIf config.aws.enable {
    home-manager.users.${config.user} = {
      home.sessionVariables = {
        GRANTED_ENABLE_AUTO_REASSUME = "true";
      };

      programs.granted = {
        enable = true;
      };

      programs.awscli = {
        enable = true;
      };

      home.shellAliases = {
        granted-refresh = lib.mkIf isDarwin "granted sso populate --sso-region eu-west-2 https://kodehort.awsapps.com/start";
      };

      programs.fish = {
        shellAliases = {
          assume = lib.mkIf isDarwin "source ${pkgs.granted}/share/assume.fish";
        };

        interactiveShellInit = ''
          set -x AWS_SDK_LOAD_CONFIG 1
        '';
      };
    };
  };
}
