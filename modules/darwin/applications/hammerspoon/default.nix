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

      home.activation.reloadHammerspoon =
        config.home-manager.users.${config.user}.lib.dag.entryAfter [ "writeBoundary" ]
          ''
            $DRY_RUN_CMD /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs -c "hs.reload()"
            $DRY_RUN_CMD sleep 1
            $DRY_RUN_CMD /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs -c "hs.console.clearConsole()"
          '';
    };

    homebrew.casks = [ "hammerspoon" ];

    system.activationScripts.postUserActivation.text = ''
      defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
      sudo killall Dock
    '';
  };
}
