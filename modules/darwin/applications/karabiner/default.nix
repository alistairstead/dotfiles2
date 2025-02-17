{ config, lib, ... }: {
  options = {
    karabiner = {
      enable = lib.mkEnableOption {
        description = "Enable karabiner.";
        default = false;
      };
    };
  };

  config = lib.mkIf (!config.ci.enable && config.gui.enable && config.karabiner.enable) {

    homebrew.casks = [ "karabiner-elements" ];
    # The nix package is not used as it was not lining the app in system prefs
    # home-manager.users.${config.user} = {
    #   home.packages = with pkgs; [
    #     karabiner-elements
    #   ];
    # };
  };
}
