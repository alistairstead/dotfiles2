{ config
, pkgs
, ...
}:
{

  home-manager.users.${config.user}.programs.starship = {
    enable = true;
    settings = {
      add_newline = true; # Print new line at the start of the prompt
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold green)";
      };
      # A continuation prompt that displays two filled-in arrows
      continuation_prompt = "..❯ ";
    };
  };
}
