{ config
, pkgs
, ...
}:
let
  # create plugin using this article: 
  # https://haseebmajid.dev/posts/2023-07-10-setting-up-tmux-with-nix-home-manager/
  tmux-nerd-font-window-name = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-nerd-font-window-name";
      rtpFilePath = "tmux-nerd-font-window-name.tmux";
      version = "unstable-2024-09-14";
      src = pkgs.fetchFromGitHub {
        owner = "joshmedeski";
        repo = "tmux-nerd-font-window-name";
        rev = "e0f3946227e5e7b5a94a24f973c842fa5a385e7f";
        sha256 = "sha256-Iv5XmJZzT20c1dkTaHZkHcxiAKEnzuNy/P22grKJrhg=";
      };
    };
in
{
  home-manager.users.${config.user} = {
    programs.tmux = {
      enable = true;
      baseIndex = 1; # Start windows and panes at 1
      escapeTime = 0; # Wait time after escape is input
      historyLimit = 100000;
      keyMode = "vi";
      newSession = true; # Automatically spawn new session
      resizeAmount = 10;
      disableConfirmationPrompt = true; # Disable confirmation prompt when closing windows
      shell = "${pkgs.fish}/bin/fish";
      terminal = "tmux-256color";
      # sensibleOnTop = false; # sensible tmux settings 
      extraConfig = ''

        # ████████╗███╗   ███╗██╗   ██╗██╗  ██╗
        # ╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝
        #    ██║   ██╔████╔██║██║   ██║ ╚███╔╝
        #    ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗
        #    ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
        #    ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
        # Terminal multiplexer
        # https://github.com/tmux/tmux

        set-option -g focus-events on
        set-option -g display-time 3000

        set -g detach-on-destroy off # don't exit from tmux when closing a session
        set -g mouse on              # enable mouse support
        set -g renumber-windows on   # renumber all windows when any window is closed
        set -g set-clipboard on      # use system clipboard
        set -g status-interval 3     # update the status bar every 3 seconds
        set -g status-position top   # macOS / darwin style

        # set -g xterm-keys on
        # set -g allow-passthrough on
        # set -ga update-environment TERM
        # set -ga update-environment TERM_PROGRAM

        set -g status-left-length 100

        bind 'h' split-window -v -c "#{pane_current_path}"
        bind 'v' split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
        bind '%' split-window -h -c "#{pane_current_path}"
        bind c new-window -c '#{pane_current_path}'

        bind -N "⌘+g lazygit " g new-window -c "#{pane_current_path}" -n " " "lazygit 2> /dev/null"
        bind -N "⌘+G gh-dash " G new-window -c "#{pane_current_path}" -n " " "ghd 2> /dev/null"

        bind -n WheelUpPane if -t = "test $(echo #{pane_current_command} |grep -iE '(n?vim|man|less)')" "select-pane -t = ; send-keys Up Up Up" "if-shell -F -t = '#{?mouse_any_flag,1,#{pane_in_mode}}' 'send-keys -M' 'select-pane -t = ; copy-mode -e; send-keys -M'"
        bind -n WheelDownPane if -t = "test $(echo #{pane_current_command} |grep -iE '(n?vim|man|less)')" "select-pane -t = ; send-keys Down Down Down" "if-shell -F -t = '#{?mouse_any_flag,1,#{pane_in_mode}}' 'send-keys -M' 'select-pane -t = ; copy-mode -e; send-keys -M'"

        # Use Alt-arrow keys without prefix key to switch panes
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # Shift arrow to switch windows
        bind -n S-Left  previous-window
        bind -n S-Right next-window

        # Shift Alt vim keys to switch windows
        bind -n M-H previous-window
        bind -n M-L next-window

        # keybindings
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
        bind-key -n 'C-h' if-shell "$is_vim" { send-keys C-h } { if-shell -F '#{pane_at_left}'   {} { select-pane -L } }
        bind-key -n 'C-j' if-shell "$is_vim" { send-keys C-j } { if-shell -F '#{pane_at_bottom}' {} { select-pane -D } }
        bind-key -n 'C-k' if-shell "$is_vim" { send-keys C-k } { if-shell -F '#{pane_at_top}'    {} { select-pane -U } }
        bind-key -n 'C-l' if-shell "$is_vim" { send-keys C-l } { if-shell -F '#{pane_at_right}'  {} { select-pane -R } }

        # bind -n '[' if-shell "$is_vim" {} { send-keys C-[ }

        bind-key -T copy-mode-vi 'C-h' if-shell -F '#{pane_at_left}'   {} { select-pane -L }
        bind-key -T copy-mode-vi 'C-j' if-shell -F '#{pane_at_bottom}' {} { select-pane -D }
        bind-key -T copy-mode-vi 'C-k' if-shell -F '#{pane_at_top}'    {} { select-pane -U }
        bind-key -T copy-mode-vi 'C-l' if-shell -F '#{pane_at_right}'  {} { select-pane -R }


        bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt (cmd+w)
        bind-key e send-keys "tmux capture-pane -p -S - | nvim -c 'set buftype=nofile' +" Enter

        bind-key "Z" display-popup -E "sesh connect \$(sesh list | zf --height 24)"

        set -g pane-active-border-style 'fg=brightblack,bg=default'
        set -g pane-border-style 'fg=brightblack,bg=default'

        # set -g status-bg default
        # set -g status-style bg=default
      '';

      plugins = with pkgs; [
        # tmuxPlugins.sensible
        tmux-nerd-font-window-name
        tmuxPlugins.vim-tmux-navigator
        {
          plugin = tmuxPlugins.yank;
          extraConfig = ''
            # tmux-yank config
            set -g @shell_mode 'vi'
          '';
        }
        {
          plugin = tmuxPlugins.tmux-fzf;
          extraConfig = ''
            bind-key "T" run-shell "sesh connect $(sesh list -tz | fzf-tmux -p 55%,60% \
              --no-sort --border-label ' sesh ' --prompt '⚡ ' \
              --header '  ^a all ^t tmux ^x zoxide ^f find' \
              --bind 'tab:down,btab:up' \
              --bind 'ctrl-a:change-prompt(⚡)+reload(sesh list)' \
              --bind 'ctrl-t:change-prompt( )+reload(sesh list -t)' \
              --bind 'ctrl-x:change-prompt( )+reload(sesh list -z)' \
              --bind 'ctrl-f:change-prompt( )+reload(fd -H -d 2 -t d -E .Trash . ~)'
            )"
          '';
        }
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            # Catppuccino theme config
            set -g @catppuccin_flavor 'mocha'
            set -g @catppuccin_window_default_fill "number"
            set -g @catppuccin_window_default_text "#W"
            set -g @catppuccin_window_left_separator "█"
            set -g @catppuccin_window_right_separator "█ "
            set -g @catppuccin_window_middle_separator "█ "
            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_status "icon"
            set -g @catppuccin_icon_window_last "null"
            set -g @catppuccin_icon_window_current "null"
            set -g @catppuccin_icon_window_zoom ""
            set -g @catppuccin_icon_window_mark "null"
            set -g @catppuccin_icon_window_silent "null"
            set -g @catppuccin_icon_window_activity "󰖲"
            set -g @catppuccin_icon_window_bell "󰂞"
            set -g @catppuccin_status_modules_right "application session"
            set -g @catppuccin_status_right_separator "█"
            set -g @catppuccin_status_left_separator "null"
            set -g @catppuccin_status_right_separator_inverse "no"
            set -g @catppuccin_status_connect_separator "no"
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"
            set -g @catppuccin_date_time_text "%H:%M"
            set -g @catppuccin_date_time_icon "null"
            set -g @catppuccin_session_icon "null"
            set -g @catppuccin_application_icon "null"
          '';
        }
      ];

    };

    xdg.configFile."tmux/tmux-nerd-font-window-name.yml".source = ./tmux-nerd-font-window-name.yml;
  };
}
