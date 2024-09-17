{ config
, pkgs
}:
{
  home-manager.users.${config.user} = {
    devshells.default = {
      packages = with pkgs; [ nix-diff ];
    };
  };
}
