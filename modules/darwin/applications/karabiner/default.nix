{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {

    homebrew.casks = [ "karabiner-elements" ];

    # home-manager.users.${config.user} = {
    #   home.packages = with pkgs; [
    #     karabiner-elements
    #   ];
    # };
  };
}
