{ config
, ...
}:
{

  config = {
    home-manager.users.${config.user} = {

      programs.bash = {
        enable = true;
        # shellAliases = config.home-manager.users.${config.user}.programs.fish.shellAliases;
        initExtra = "";
        profileExtra = "";
      };

      programs.starship.enableBashIntegration = true;
      programs.zoxide.enableBashIntegration = true;
      programs.fzf.enableBashIntegration = true;
    };
  };
}
