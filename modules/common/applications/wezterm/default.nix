{ config, pkgs , lib , ... }: {
  options = {
    wezterm = {
      enable = lib.mkEnableOption {
        description = "Enable WezTerm terminal.";
        default = false;
      };
    };
  };

  config =
    lib.mkIf (!config.ci.enable && config.gui.enable && config.wezterm.enable) {

      # Set the Rofi-Systemd terminal for viewing logs
      # Using optionalAttrs because only available in NixOS
      environment =
        { }
        // lib.attrsets.optionalAttrs (builtins.hasAttr "sessionVariables" config.environment) {
          sessionVariables.ROFI_SYSTEMD_TERM = "${pkgs.wezterm}/bin/wezterm";
        };

      home-manager.users.${config.user} = {

        # Set the i3 terminal
        xsession.windowManager.i3.config.terminal = lib.mkIf pkgs.stdenv.isLinux "wezterm";

        # Set the Rofi terminal for running programs
        programs.rofi.terminal = lib.mkIf pkgs.stdenv.isLinux "${pkgs.wezterm}/bin/wezterm";

        # Display images in the terminal
        programs.fish.shellAliases = {
          icat = lib.mkForce "wezterm imgcat";
        };

        programs.wezterm = {
          enable = true;
          package = pkgs.wezterm;

          extraConfig = builtins.readFile (pkgs.substituteAll {
            src = ./wezterm.lua;

            env = {
            };
          });
        };
      };
    };
}
