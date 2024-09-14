{ config
, pkgs
, ...
}:
{

  config = {
    home-manager.users.${config.user} = {
      programs.eza = {
        enable = true;
        icons = true;

        extraOptions = [
          "--group-directories-first"
          "--no-quotes"
          "--git-ignore"
          "--icons=always"
        ];
      };

    };

    programs.fish.shellAliases = {
      # Use eza (exa) instead of ls for fancier output
      ls = "${pkgs.eza}/bin/eza";
    };

  };
}
