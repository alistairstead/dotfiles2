{ config
, pkgs
, lib
, ...
}:
# let
#   # util = (import ./util.nix) { config = config; };
# in
{

  config = lib.mkIf pkgs.stdenv.isDarwin {

    users.knownUsers = [ config.user ];

    users.users."${config.user}" = {
      # macOS user
      home = config.homePath;
      shell = pkgs.fish;
      uid = 501;
    };

    # This might fix the shell issues
    # users.knownUsers = [ config.user ];

    home-manager.users.${config.user} = {
      # Default shell setting doesn't work
      home.sessionVariables = {
        SHELL = "${pkgs.fish}/bin/fish";
      };

      # Used for aerc
      xdg.enable = true;

      # xdg.configFile."karabiner/karabiner.json".source = util.link "config/karabiner/karabiner.json";
    };

    # Fix for: 'Error: HOME is set to "/var/root" but we expect "/var/empty"'
    home-manager.users.root.home.homeDirectory = lib.mkForce "/var/root";
  };
}
