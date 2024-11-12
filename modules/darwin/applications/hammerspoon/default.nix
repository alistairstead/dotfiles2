{
  config,
  pkgs,
  lib,
  ...
}:
{

  # Hammerspoon - MacOS custom automation scripting

  config = lib.mkIf pkgs.stdenv.isDarwin {

    home-manager.users.${config.user} = {
      xdg.configFile."hammerspoon/init.lua".source = ./init.lua;
      xdg.configFile."hammerspoon/Spoons/ControlEscape.spoon".source = ./Spoons/ControlEscape.spoon;
    };

    homebrew.casks = [ "hammerspoon" ];

    system.activationScripts.postUserActivation.text = ''
      defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"
      sudo killall Dock
    '';
  };
}
