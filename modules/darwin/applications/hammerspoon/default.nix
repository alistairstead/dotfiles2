{ config, lib, ... }: {
  # Hammerspoon - MacOS custom automation scripting
  options = {
    hammerspoon = {
      enable = lib.mkEnableOption {
        description = "Enable Hammerspoon.";
        default = false;
      };
    };
  };

  config = lib.mkIf (!config.ci.enable && config.gui.enable && config.hammerspoon.enable) {

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
