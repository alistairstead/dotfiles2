{ config
, lib
, pkgs
, ...
}:
{
  imports = [
    # ./applications
    # ./programming
    ./repositories
    ./shell
  ];

  options = {
    user = lib.mkOption {
      type = lib.types.str;
      description = "Primary user of the system";
    };
    fullName = lib.mkOption {
      type = lib.types.str;
      description = "Human readable name of the user";
    };
    userDirs = {
      # Required to prevent infinite recursion when referenced by himalaya
      download = lib.mkOption {
        type = lib.types.str;
        description = "XDG directory for downloads";
        default = if pkgs.stdenv.isDarwin then "$HOME/Downloads" else "$HOME/downloads";
      };
    };
    gitName = lib.mkOption {
      type = lib.types.str;
      description = "Name to use for git commits";
    };
    gitEmail = lib.mkOption {
      type = lib.types.str;
      description = "Email to use for git commits";
    };
    ci = {
      enable = lib.mkEnableOption {
        description = "Running in CI.";
        default = false;
      };
    };
    gui = {
      enable = lib.mkEnableOption {
        description = "Enable graphics.";
        default = false;
      };
    };
    homePath = lib.mkOption {
      type = lib.types.path;
      description = "Path of user's home directory.";
      default = builtins.toPath (
        if pkgs.stdenv.isDarwin then "/Users/${config.user}" else "/home/${config.user}"
      );
    };
    dotfilesPath = lib.mkOption {
      type = lib.types.path;
      description = "Path of dotfiles repository.";
      default = config.homePath + "/dev/personal/dotfiles";
    };
    dotfilesRepo = lib.mkOption {
      type = lib.types.str;
      description = "Link to dotfiles repository HTTPS URL.";
    };
    unfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of unfree packages to allow.";
      default = [ ];
    };
  };

  config = {
    # Basic common system packages for all devices


    # Allow specified unfree packages (identified elsewhere)
    # Retrieves package object based on string name
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfreePackages;
  };
}
