{ config
, lib
, pkgs
, ...
}:
{

  options.aws.enable = lib.mkEnableOption "AWS tools.";

  config = lib.mkIf config.aws.enable {
    home-manager.users.${config.user} = {

      home.packages = with pkgs; [
        granted
      ];

      programs.awscli = {
        enable = true;
      };
      programs.fish = {
        interactiveShellInit = ''
          set -x AWS_SDK_LOAD_CONFIG 1
        '';
      };
    };
  };
}
