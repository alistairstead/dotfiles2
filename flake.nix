{
  description = "My system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Used for MacOS system config
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used for user packages and dotfiles
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list for their inputs
    };

    # Catppuccino theme
    catppuccin.url = "github:catppuccin/nix";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # Better App install management in macOS
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list for their inputs
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, ... }@inputs:
    let
      nixpkgsConfig = {
        allowUnfree = true;
        allowUnsupportedSystem = false;
      };

      unstable = import inputs.nixpkgs-unstable { inherit system; };
      envUsername = builtins.getEnv "USERNAME";
      envHostname = builtins.getEnv "HOSTNAME";
      user = if envUsername == "" then "alistairstead" else envUsername;
      hostname = if envHostname == "" then "wombat" else envHostname;
      isCI = builtins.getEnv "CI" == "true";
      globals =
        rec {
          inherit user;
          fullName = "Alistair Stead";
          gitName = fullName;
          gitEmail = "62936+alistairstead@users.noreply.github.com";
          dotfilesRepo = "https://github.com/alistairstead/dotfiles2";
          ci.enable = isCI;
        };

      # Common overlays to always use
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
        (import ./overlays/granted.nix)
        (import ./overlays/tmux.nix inputs)
      ];
      system = "aarch64-darwin";
    in {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
      # Contains my full Mac system builds, including home-manager
      # darwin-rebuild switch --flake .#wombat
      darwinConfigurations.${hostname} = darwin.lib.darwinSystem {
        inherit system;
        # makes all inputs available in imported files
        specialArgs = { inherit inputs; inherit unstable; };
          modules = [
            ({ pkgs, inputs, ... }: {
              nixpkgs.config = nixpkgsConfig;
              nixpkgs.overlays = overlays;

              system = {
                stateVersion = 4;
                configurationRevision = self.rev or self.dirtyRev or null;
              };

              users.users.${user} = {
                home = "/Users/${user}";
              };

              networking = {
                computerName = hostname;
                hostName = hostname;
                localHostName = hostname;
              };

              nix = {
                # enable flakes per default
                package = pkgs.nixVersions.stable;
                # Set automatic generation cleanup for home-manager
                gc = {
                  automatic = false;
                  user = user;
                  options = "--delete-older-than 30d";
                };
                settings = {
                  allowed-users = [ user ];
                  experimental-features = [ "nix-command" "flakes" ];
                  warn-dirty = false;
                  # produces linking issues when updating on macOS
                  # https://github.com/NixOS/nix/issues/7273
                  auto-optimise-store = false;
                };
              };
            })
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                # makes all inputs available in imported files for hm
                extraSpecialArgs = {
                  inherit inputs;
                  inherit unstable;
                  pkgs-zsh-fzf-tab =
                    import inputs.nixpkgs-zsh-fzf-tab { inherit system; };
                };
                users.${user} = { ... }: {
                    home.stateVersion = "23.11";
                  };
                users.root = { ... }: {
                    home.stateVersion = "23.11";
                  };
              };
            }
            {
              gui.enable = true;

              # charm.enable = true;
              neovim.enable = true;
              discord.enable = true;
              dotfiles.enable = true;
              aws.enable = true;
              obsidian.enable = true;
              _1password.enable = true;
              slack.enable = true;
              wezterm.enable = false;
              ghostty.enable = true;
              raycast.enable = true;
              devenv.enable = true;
              node.enable = true;
              php.enable = true;
              go.enable = true;
              aerospace.enable = false;
              terraform.enable = true;
            }
            (globals)
            ./modules/common
            ./modules/darwin
            inputs.mac-app-util.darwinModules.default
          ];

      };

      # For quickly applying home-manager settings with:
      # home-manager switch --flake .#wombat
      # homeConfigurations = {
      #   wombat = darwinConfigurations.wombat.config.home-manager.users.${globals.user}.home;
      # };

      # Programs that can be run by calling this flake
      # apps = forAllSystems (
      #   system:
      #   let
      #     pkgs = import nixpkgs { inherit system overlays; };
      #   in
      #   import ./apps { inherit pkgs; }
      # );

      # Development environments
      # devShells = forAllSystems (
      #   system:
      #   let
      #     pkgs = import nixpkgs { inherit system overlays; };
      #   in
      #   {
      #     # Used to run commands and edit files in this repo
      #     default = pkgs.mkShell {
      #       buildInputs = with pkgs; [
      #         git
      #       ];
      #     };
      #   }
      # );
    };
}


