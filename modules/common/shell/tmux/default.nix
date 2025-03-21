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
        rev = "3def0b9c57b16e2c2fe4ec55555f5698444e5cee";
        sha256 = "sha256-NcRf4v7QxsWk8w4maWFVlSpq/d+QHrGqFpCw2NxZ/I8=";
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

        bind 'h' split-window -v -c "#{pane_current_path}"
        bind 'v' split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
        bind '%' split-window -h -c "#{pane_current_path}"
        bind c new-window -c '#{pane_current_path}'

        bind -N "⌘+d lazydocker " d new-window -c "#{pane_current_path}" -n " " "lazydocker 2> /dev/null"
        bind -N "⌘+g lazygit " g new-window -c "#{pane_current_path}" -n " " "lazygit 2> /dev/null"
        bind -N "⌘+G gh-dash " G new-window -c "#{pane_current_path}" -n " " "ghd 2> /dev/null"
        bind -N "⌘+⇧+t break pane" B break-pane
        bind -N "⌘+^+t join pane" J join-pane -t 1

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

      '';

      plugins = with pkgs; [
        # tmuxPlugins.sensible
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
            bind-key "K" display-popup -E -w 33% -h 63% "sesh connect $(
              sesh list -i | gum filter --limit 1 --fuzzy --no-sort --placeholder 'Pick a sesh' --prompt='⚡'
            )"

            bind-key "R" display-popup -E -w 40% "sesh connect $(
              sesh list -i -H | gum filter --value \"\$(sesh root)\" --limit 1 --fuzzy --no-sort --placeholder 'Pick a sesh' --prompt='⚡'
            )"

            # bind-key "K" display-popup -E -w 40% "sesh connect $(
            #   sesh list -i | gum filter --limit 1 --fuzzy --no-sort --placeholder 'Pick a sesh' --prompt='⚡'
            # )"

            bind-key "A" display-popup -E -w 40% "sesh connect $(
              fabric -l | gum filter --limit 1 --fuzzy --no-sort --placeholder 'Pick a fabric pattern' --prompt='🧠'
            )"

            bind-key "T" run-shell "sesh connect $(sesh list -tz | fzf-tmux -p 55%,60% \
              --no-sort --border-label ' sesh ' --prompt '⚡ ' \
              --header '  ^a all ^t tmux ^x zoxide ^f find' \
              --bind 'tab:down,btab:up' \
              --bind 'ctrl-a:change-prompt(⚡)+reload(sesh list)' \
              --bind 'ctrl-t:change-prompt( )+reload(sesh list -t)' \
              --bind 'ctrl-x:change-prompt( )+reload(sesh list -z)' \
              --bind 'ctrl-f:change-prompt( )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
              --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list)'
            )"
          '';
        }
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            # Catppuccino theme config

            set -ogq @catppuccin_flavor "mocha"
            set -ogq @catppuccin_window_status_style "basic"
            set -ogq @catppuccin_icon_window_last "null"
            set -ogq @catppuccin_icon_window_current "null"
            set -ogq @catppuccin_icon_window_zoom ""
            set -ogq @catppuccin_icon_window_mark "null"
            set -ogq @catppuccin_icon_window_silent "null"
            set -ogq @catppuccin_icon_window_activity "󰖲"
            set -ogq @catppuccin_icon_window_bell "󰂞"

            set -ogq @catppuccin_status_left_separator "█"
            set -ogq @catppuccin_status_middle_separator ""
            set -ogq @catppuccin_status_right_separator "█"
            set -ogq @catppuccin_status_connect_separator "no" # yes, no
            set -ogq @catppuccin_status_fill "icon"
            set -ogq @catppuccin_status_module_bg_color "#{@thm_surface_0}"
            set -ogq @catppuccin_date_time_text "%H:%M"
            set -ogq @catppuccin_date_time_icon ""
            set -ogq @catppuccin_session_icon ""
            set -ogq @catppuccin_application_icon ""

            set -g status-right-length 100
            set -g status-left-length 100
            set -g status-left ""
            set -g status-right "#{E:@catppuccin_status_session}"

            set -g @catppuccin_window_default_text "  #W"
            set -g @catppuccin_window_current_text "  #W"
            set -g @catppuccin_window_text "  #W"
          '';
        }
        tmux-nerd-font-window-name
      ];

    };

    xdg.configFile."tmux/tmux-nerd-font-window-name.yml".source = ./tmux-nerd-font-window-name.yml;
  };
}
