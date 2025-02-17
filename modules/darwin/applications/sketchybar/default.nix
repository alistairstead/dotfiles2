{ config, lib, inputs, ... }:
let 
  folder = "${inputs.sketchybar}/.config/sketchybar";
in {
  options = {
    sketchybar = {
      enable = lib.mkEnableOption {
        description = "Enable Sketchybar.";
        default = false;
      };
    };
  };

  config = lib.mkIf (!config.ci.enable && config.gui.enable && config.sketchybar.enable) {

    services.sketchybar = {
      enable = true;
    };

    homebrew = {

      casks = [
        "font-hack-nerd-font"
      ];
    };

    home-manager.users.${config.user} = {

    };
  };
}
