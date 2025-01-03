{ config
, pkgs
, lib
, ...
}:
{
  programs.fish.enable = true; # Needed for LightDM to remember username

  home-manager.users.${config.user} = {

    # Packages used in abbreviations and aliases
    home.packages = with pkgs; [ curl ];

    programs.fish = {
      enable = true;
      shellAliases = {
        # Version of bash which works much better on the terminal
        bash = "${pkgs.bashInteractive}/bin/bash";

        # Move files to XDG trash on the commandline
        trash = lib.mkIf pkgs.stdenv.isLinux "${pkgs.trash-cli}/bin/trash-put";
      };
      functions = {
        # fish_user_key_bindings = {
        #   body = builtins.readFile ./functions/fish_user_key_bindings.fish;
        # };
        # commandline-git-commits = {
        #   description = "Insert commit into commandline";
        #   body = builtins.readFile ./functions/commandline-git-commits.fish;
        # };
        copy = {
          description = "Copy file contents into clipboard";
          body = "cat $argv | pbcopy"; # Need to fix for non-macOS
        };
        # edit = {
        #   description = "Open a file in Vim";
        #   body = builtins.readFile ./functions/edit.fish;
        # };
        envs = {
          description = "Evaluate a bash-like environment variables file";
          body = ''set -gx (cat $argv | tr "=" " " | string split ' ')'';
        };
        # fcd = {
        #   description = "Jump to directory";
        #   argumentNames = "directory";
        #   body = builtins.readFile ./functions/fcd.fish;
        # };
        # ip = {
        #   body = builtins.readFile ./functions/ip.fish;
        # };
        # json = {
        #   description = "Tidy up JSON using jq";
        #   body = "pbpaste | jq '.' | pbcopy"; # Need to fix for non-macOS
        # };
        # note = {
        #   description = "Edit or create a note";
        #   argumentNames = "filename";
        #   body = builtins.readFile ./functions/note.fish;
        # };
        # recent = {
        #   description = "Open a recent file in Vim";
        #   body = builtins.readFile ./functions/recent.fish;
        # };
        # search-and-edit = {
        #   description = "Search and open the relevant file in Vim";
        #   body = builtins.readFile ./functions/search-and-edit.fish;
        # };
        # syncnotes = {
        #   description = "Full git commit on notes";
        #   body = builtins.readFile ./functions/syncnotes.fish;
        # };
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
      shellAbbrs = {

        # Directory aliases
        "-" = "cd -";

        # Vim (overwritten by Neovim)
        v = "nvim";
        vim = "nvim";
        vl = "vim -c 'normal! `0'";

      };
      shellInit = "";
    };

    # Global fzf configuration
    home.sessionVariables =
      {
        fish_greeting = "";
        EDITOR = "nvim";
        GIT_EDITOR = "nvim";
        VISUAL = "nvim";
        FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
      };

    programs.starship.enableFishIntegration = true;
    programs.zoxide.enableFishIntegration = true;
    programs.fzf.enableFishIntegration = true;
  };
}


