{ config, pkgs , lib, ...}: {
  home-manager.users.${config.user} = {
    home.shellAliases = {
      n = "nix";
      ns = "nix-shell -p";
      nsf = "nix-shell --run fish -p";
      nps = "nix repl '<nixpkgs>'";
      nixo = "man configuration.nix";
      nixh = "man home-configuration.nix";
    };

    programs.fish = {
      shellAbbrs = {
        nr = "rebuild-nixos";
        nro = "rebuild-nixos offline";
        hm = "rebuild-home";
      };
      functions = {
        rebuild-nixos = {
          body = ''
            if test "$argv[1]" = "offline"
                set option "--option substitute false"
            end
            git -C ${config.dotfilesPath} add --intent-to-add --all
            commandline -r "doas nixos-rebuild switch $option --flake ${config.dotfilesPath}#${config.networking.hostName}"
            commandline --function execute
          '';
        };
        rebuild-home = {
          body = ''
            git -C ${config.dotfilesPath} add --intent-to-add --all
            commandline -r "${pkgs.home-manager}/bin/home-manager switch --flake ${config.dotfilesPath}#${config.networking.hostName}";
            commandline --function execute
          '';
        };
      };
    };

    # Provides "command-not-found" options
    programs.nix-index = {
      enableFishIntegration = true;
    };

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
