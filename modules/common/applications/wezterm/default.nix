{ config
, pkgs
, lib
, ...
}:
{

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
              # weztermStatus = let
              #   pkg = pkgs.fetchgit {
              #     url = "https://github.com/yriveiro/wezterm-status.git";
              #     rev = "665cc2f33a97a20c61288706bedf3b2fc95c2399";
              #     hash = "sha256-Fww+MDT006NWr8hlYzLCBlj72LNbAxaCHj8rfonXar4=";
              #     leaveDotGit = true;
              #   };
              # in "file://${pkg}";
              # wezPerProjectWorkspace = let
              #   pkg = pkgs.fetchgit {
              #     url = "https://github.com/sei40kr/wez-per-project-workspace.git";
              #     rev = "1fa76b0cd8025c0d445895cb835bedddff077657";
              #     hash = "sha256-WXnCdo7WSZIW5gZoTkHGEwKvhBq2roMcojm6nXeiY60=";
              #     leaveDotGit = true;
              #   };
              # in "file://${pkg}";
              # weztermStatus = "https://github.com/yriveiro/wezterm-status";
            };
          });
        };
      };
    };
}
