{ config
, ...
}:
{
  home-manager.users.${config.user} = {
    programs.eza = {
      enable = true;
      icons = "auto";

      extraOptions = [
        # "--group-directories-first"
        # "--no-quotes"
        # "--git-ignore"
      ];
    };

  };

}
