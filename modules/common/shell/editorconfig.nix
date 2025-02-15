{ config, ... }: {
  home-manager.users.${config.user} = {

    # `toINIWithGlobalSection` will escape `[shell]` to `\[shell\]`, use home.file.<name>.txt here
    # man shfmt
    home.file.".editorconfig".text = ''
      [shell]
      indent_style = space
      indent_size = 2
      max_line_length = 120
    '';
  };
}
