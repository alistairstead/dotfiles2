{ config, lib , pkgs , ... }: let
  inherit (lib) getExe;
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

    home-manager.users.${config.user} = {
      home.activation = {
          yabai-reloader = ''
            run yabai --restart-service
            run sudo yabai --load-sa
          '';
        };
    };

    services.yabai = {
      enable = true;
      package = pkgs.yabai;
      enableScriptingAddition = true;
      config = {
        auto_balance = "on";
        layout = "bsp";
        mouse_modifier = "alt";
        top_padding = 10;
        bottom_padding = 10;
        left_padding = 10;
        right_padding = 10;
        window_gap = 10;
        window_shadow = "float";
      };
      # https://github.com/koekeishiya/yabai/issues/1297#issuecomment-1318403190
      # yabai -m query --windows --space
      extraConfig = 
        with pkgs; #bash
        ''
        # ██╗   ██╗ █████╗ ██████╗  █████╗ ██╗
        # ╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗██║
        #  ╚████╔╝ ███████║██████╔╝███████║██║
        #   ╚██╔╝  ██╔══██║██╔══██╗██╔══██║██║
        #    ██║   ██║  ██║██████╔╝██║  ██║██║
        #    ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝
        # A tiling window manager for macOS
        # https://github.com/koekeishiya/yabai

        # Set external_bar here in case we launch after sketchybar
        BAR_HEIGHT=$(${getExe sketchybar} -m --query bar | jq -r '.height')
        ${getExe config.services.yabai.package} -m config external_bar all:"$BAR_HEIGHT":0

        ${builtins.readFile ./extraConfig}

        # Signal hooks
        ${getExe config.services.yabai.package} -m signal --add event=dock_did_restart action="sudo ${getExe config.services.yabai.package} --load-sa"
        ${getExe config.services.yabai.package} -m signal --add event=window_focused action="${getExe sketchybar} --trigger window_focus"
        ${getExe config.services.yabai.package} -m signal --add event=window_created action="${getExe sketchybar} --trigger windows_on_spaces"
        ${getExe config.services.yabai.package} -m signal --add event=window_destroyed action="${getExe sketchybar} --trigger windows_on_spaces"

        setup_space() {
          local idx="$1"
          local name="$2"
          yabai -m space "$idx" --label "$name"
        }

        yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
        sudo yabai --load-sa

        # yabai -m signal --add event=window_resized action='sleep 2'
        # yabai -m signal --add event=window_moved action='sleep 2'

        # global settings
        yabai -m config mouse_follows_focus off
        yabai -m config focus_follows_mouse off
        yabai -m config window_origin_display default
        yabai -m config window_placement second_child
        yabai -m config window_topmost off
        yabai -m config window_shadow on
        yabai -m config window_opacity off
        yabai -m config window_opacity_duration 0.0
        yabai -m config active_window_opacity 1.0
        yabai -m config normal_window_opacity 0.90
        yabai -m config window_border off
        yabai -m config window_border_width 6
        yabai -m config active_window_border_color 0xff775759
        yabai -m config normal_window_border_color 0xff555555
        yabai -m config insert_feedback_color 0xffd75f5f
        yabai -m config split_ratio 0.50
        yabai -m config auto_balance off
        yabai -m config mouse_modifier fn
        yabai -m config mouse_action1 move
        yabai -m config mouse_action2 resize
        yabai -m config mouse_drop_action swap

        # modify window shadows (default: on, options: on, off, float)
        # example: show shadows only for floating windows
        # yabai -m config window_shadow float

        # general space settings
        yabai -m config layout bsp # bsp, stack, float, or chain
        yabai -m config top_padding 10
        yabai -m config bottom_padding 10
        yabai -m config left_padding 10
        yabai -m config right_padding 10
        yabai -m config window_gap 10

        # # Spaces adjustment
        # num_displays=$(yabai -m query --displays | jq 'length')
        # if [[ "$num_displays" -eq 3 ]]; then
        #   adjust_spaces 3 3 4
        # elif [[ "$num_displays" -eq 2 ]]; then
        #   adjust_spaces 5 5
        # elif [[ "$num_displays" -eq 1 ]]; then
        #   adjust_spaces 10
        # fi

        # Spaces setup
        setup_space 1 terminal
        setup_space 2 browser
        setup_space 3 notes
        setup_space 4 chat
        setup_space 5 calendar
        setup_space 6 email
        setup_space 7 social
        setup_space 8 spare
        setup_space 9 music
        setup_space 10 other

        # apps to not manage (ignore)
        yabai -m rule --add app="^System Settings$" manage=off
        # yabai -m rule --add app='^1Password' manage=off
        yabai -m rule --add app='^Around' manage=off
        # yabai -m rule --add app='^Messages' manage=off

        yabai -m rule --add app="^Ghostty$" space=^1
        yabai -m rule --add app="^Safari$" space=^2
        yabai -m rule --add app="^Google Chrome$" space=^2
        yabai -m rule --add app="^Todoist$" space=^3
        yabai -m rule --add app="^Obsidian$" space=^3
        yabai -m rule --add app="^Spark Desktop$" space=^6
        yabai -m rule --add app-"^Messages$" space=^4
        yabai -m rule --add app="^Twitter$" space=^7
        yabai -m rule --add app="^Slack$" space=^4
        yabai -m rule --add app="^Calendar$" space=^5
        yabai -m rule --add app="^Music$" space=^9

        echo "yabai configuration loaded.."
      '';
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
