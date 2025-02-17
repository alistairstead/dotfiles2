{ config, ... }: {
  # FZF is a fuzzy-finder for the terminal
  home-manager.users.${config.user} = {
    programs.fzf = {
      enable = true;
      defaultCommand =
          "fd --type f --hidden --follow --exclude .git --exclude .vim --exclude .cache --exclude vendor --exclude node_modules";
      defaultOptions = [
          "--height 50%"
          "--border sharp"
          "--inline-info"
        ];
    };

    home = {
      shellAliases = {
        lsf = "ls -lh | fzf";
      };
    };

  };
}
