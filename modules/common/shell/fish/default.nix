{ config, pkgs, ...}: {
  programs.fish.enable = true; # Needed for LightDM to remember username
  home-manager.users.${config.user} = {
    programs.fish = {
      enable = true;
      functions = {
        ping = {
          description = "Improved ping";
          argumentNames = "target";
          body = "${pkgs.prettyping}/bin/prettyping --nolegend $target";
        };
        copy = {
          description = "Copy file contents into clipboard";
          body = "cat $argv | pbcopy"; # Need to fix for non-macOS
        };
        envs = {
          description = "Evaluate a bash-like environment variables file";
          body = ''set -gx (cat $argv | tr "=" " " | string split ' ')'';
        };
      };
      interactiveShellInit = ''
        fish_vi_key_bindings
        bind -M insert -m default jk backward-char force-repaint
        bind -M insert \ce forward-char

        bind yy fish_clipboard_copy
        bind Y fish_clipboard_copy
        bind -M visual y fish_clipboard_copy
        bind -M default p fish_clipboard_paste
        bind -M insert \ce forward-char

        set -g fish_vi_force_cursor
        set -g fish_cursor_default block
        set -g fish_cursor_insert line
        set -g fish_cursor_visual block
        set -g fish_cursor_replace_one underscore
      '';
      loginShellInit = "";
      shellInit = "";
    };

    home.sessionVariables =
      {
        fish_greeting = "";
      };

    # Provides "command-not-found" options
    programs.nix-index = {
      enableFishIntegration = true;
    };

    programs.starship.enableFishIntegration = true;
    programs.zoxide.enableFishIntegration = true;
    programs.fzf.enableFishIntegration = true;
  };
}


