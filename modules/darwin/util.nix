{ config, home-manager,... }:

rec {
  dot = path: "${config.home.homeDirectory}/dev/personal/dotfiles/${path}";

  link-all = from: to:
    let
      paths = builtins.attrNames (
        builtins.readDir (../.. + "/${from}")
      );
      mkPath = path:
        let
          orig = "${from}/${path}";
        in
          {
            name = "${to}/${path}";
            value = {
              source = link orig;
            };
          };
    in
      builtins.listToAttrs (
        map mkPath paths
      );

  link = path:
    let
      fullpath = dot path;
    in
      config.lib.file.mkOutOfStoreSymlink fullpath;
}
