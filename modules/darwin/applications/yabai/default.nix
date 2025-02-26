{ config, lib , pkgs , ... }: let
  inherit (lib) getExe;
  yabaiHelper = pkgs.writeShellScriptBin "yabai-helper" ''
    ${builtins.readFile ./yabai-helper}
  '';
  yabaiExecutable = "${getExe config.services.yabai.package}";
in {
  options = {
    yabai = {
      enable = lib.mkEnableOption {
        description = "Enable Yabai.";
        default = false;
      };
    };
  };
  config = lib.mkIf (!config.ci.enable && config.gui.enable && config.yabai.enable) {

    home-manager.users.${config.user} = { pkgs, lib, ... }: {
      home.shellAliases = {
        restart-yabai = ''launchctl kickstart -k gui/"$(id -u)"/org.nixos.yabai'';
      };

      home.activation = {
        yabaiReload = ''
          # run ${yabaiExecutable} --restart-service
          run /usr/bin/sudo ${yabaiExecutable} --load-sa
        '';
      };

      xdg.configFile."yabai/yabairc".text = 
        #bash
        ''
          # ██╗   ██╗ █████╗ ██████╗  █████╗ ██╗
          # ╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗██║
          #  ╚████╔╝ ███████║██████╔╝███████║██║
          #   ╚██╔╝  ██╔══██║██╔══██╗██╔══██║██║
          #    ██║   ██║  ██║██████╔╝██║  ██║██║
          #    ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝
          # A tiling window manager for macOS
          # https://github.com/koekeishiya/yabai
          
          sudo yabai --load-sa

          # Signal hooks
          ${getExe config.services.yabai.package} -m signal --add event=dock_did_restart action="sudo ${getExe config.services.yabai.package} --load-sa"
          ${getExe config.services.yabai.package} -m signal --add event=space_changed action="nohup open -g raycast://extensions/krzysztoff1/yabai/screens-menu-bar?launchType=background > /dev/null 2>&1 &"

          # global settings
          yabai -m config mouse_follows_focus off
          yabai -m config focus_follows_mouse off
          yabai -m config window_origin_display default
          yabai -m config window_placement second_child
          yabai -m config window_insertion_point last
          yabai -m config window_topmost on
          yabai -m config window_shadow on
          yabai -m config window_opacity off
          yabai -m config window_opacity_duration 0.25
          yabai -m config active_window_opacity 1.0
          yabai -m config normal_window_opacity 0.9
          yabai -m config window_border on
          yabai -m config insert_feedback_color 0xFF659D30
          yabai -m config split_ratio 0.50
          yabai -m config auto_balance off
          yabai -m config mouse_modifier fn
          yabai -m config mouse_action1 move
          yabai -m config mouse_action2 resize
          yabai -m config mouse_drop_action swap

          # general space settings
          yabai -m config layout bsp # bsp, stack, float, or chain
          yabai -m config top_padding 10
          yabai -m config bottom_padding 10
          yabai -m config left_padding 10
          yabai -m config right_padding 10
          yabai -m config window_gap 10

          ${builtins.readFile ./extraConfig}

          echo "yabai configuration loaded.."
        '';

      home.packages = with pkgs; [
        bc
        coreutils
        jq
        yabaiHelper
        yabai
      ];

    };

    services.yabai = {
      enable = true;
      package = pkgs.yabai;
      enableScriptingAddition = true;
    };

    # https://github.com/koekeishiya/yabai#requirements-and-caveats
    system.defaults.CustomUserPreferences = {
      "com.apple.dock" = {
        # Automatically rearrange Spaces based on most recent use -> [ ]
        mru-spaces = 0;
      };
      "com.apple.WindowManager" = {
        # Show Items -> On Desktop -> [x]
        StandardHideDesktopIcons = 0;
        # Click wallpaper to reveal Desktop -> Only in Stage Manager
        EnableStandardClickToShowDesktop = 0;
      };
    };

    # system.activationScripts.preActivation.text = ''
    #   ${pkgs.sqlite}/bin/sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' \
    #     "INSERT or REPLACE INTO access(service,client,client_type,auth_value,auth_reason,auth_version) VALUES('kTCCServiceAccessibility','${pkgs.yabai}/bin/yabai',1,2,4,1);"
    # '';
    # system.activationScripts.postActivation.text = ''
    #   ${pkgs.sqlite}/bin/sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' \
    #     "DELETE from access where client_type = 1 and client != '${pkgs.yabai}/bin/yabai' and client like '%/bin/yabai';"
    # '';
  };
}
