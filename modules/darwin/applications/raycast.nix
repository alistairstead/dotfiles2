{ config
, pkgs
, lib
, ...
}:
{
  options = {
    raycast = {
      enable = lib.mkEnableOption {
        description = "Enable Raycast.";
        default = false;
      };
    };
  };

  config = lib.mkIf (!config.ci.enable && config.gui.enable && config.raycast.enable) {
    # unfreePackages = [ "raycast" ];
    # home-manager.users.${config.user} = {
    #   home.packages = [
    #     pkgs.raycast
    #   ];
    # };

    homebrew = {
      enable = true;
      # taps = [
      #   "raycast/homebrew-raycast"
      # ];
      casks = [
        "raycast"
      ];
    };  
  };
}
