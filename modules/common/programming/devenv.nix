{ config
, pkgs
, lib
, ...
}:
{

  options.devenv.enable = lib.mkEnableOption "Devenv tools.";
  config = lib.mkIf config.devenv.enable {
    nix.settings = {
      trusted-users = [
        "root"
        config.user
      ];
    };
    # DevEnv setup and documentation
    # https://devenv.sh/getting-started/#2-install-devenv
    environment.systemPackages = with pkgs; [
      devenv
    ];
  };
}
