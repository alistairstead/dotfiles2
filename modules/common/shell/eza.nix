{ config
, pkgs
, ...
}:
{
  home-manager.users.${config.user} = {
    programs.eza = {
      enable = true;
      icons = true;

      extraOptions = [
        "--group-directories-first"
        "--no-quotes"
        "--git-ignore"
      ];
    };

  };

}
