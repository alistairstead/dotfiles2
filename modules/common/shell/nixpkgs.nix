{ config, pkgs , lib, ...}: {
  home-manager.users.${config.user} = {
    # Create nix-index if doesn't exist
    home.activation.createNixIndex =
      let
        cacheDir = "${config.homePath}/.cache/nix-index";
      in
      lib.mkIf config.home-manager.users.${config.user}.programs.nix-index.enable (
        config.home-manager.users.${config.user}.lib.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d ${cacheDir} ]; then
              $DRY_RUN_CMD ${pkgs.nix-index}/bin/nix-index -f ${pkgs.path}
          fi
        ''
      );

  };
}
