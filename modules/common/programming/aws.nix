{ config
, lib
, pkgs
, ...
}:
{

  options.aws.enable = lib.mkEnableOption "AWS tools.";

  config = lib.mkIf config.aws.enable {
    # Enables quickly entering Nix shells when changing directories
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [
        "granted" # AWS access https://github.com/common-fate/granted
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
