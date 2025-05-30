{ config
, ...
}:
{

  config = {
    home-manager.users.${config.user} = {

      programs.zsh = {
        enable = true;
        shellAliases = config.home-manager.users.${config.user}.programs.fish.shellAliases;
        initExtra = "";
        profileExtra = "";
        history = {
          save = 10000;
          append = true;
          expireDuplicatesFirst = true;
          ignoreDups = true;
          ignoreSpace = true;
        };
      };

      programs.starship.enableZshIntegration = true;
      programs.zoxide.enableZshIntegration = true;
      programs.fzf.enableZshIntegration = true;
    };
  };
}
