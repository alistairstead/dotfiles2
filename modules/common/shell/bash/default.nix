{ config
, ...
}:
{

  config = {
    home-manager.users.${config.user} = {

      programs.bash = {
        enable = true;
        initExtra = "";
        profileExtra = "";
      };

      programs.starship.enableBashIntegration = true;
      programs.zoxide.enableBashIntegration = true;
      programs.fzf.enableBashIntegration = true;
    };
  };
}
