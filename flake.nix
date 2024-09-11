{
  description = "My system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Used for specific stable packages
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

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

    # Better App install management in macOS
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list for their inputs
    };
  };

  outputs = inputs@{ self, darwin, nixpkgs, home-manager }:
    let
      # Global configuration for my systems
      globals =
        let
          username = builtins.getEnv "USERNAME";
          loggedUsername = builtins.trace "The value of USERNAME environment variable is: ${toString username}" username;
          isCI = builtins.getEnv "CI" == "true";
          loggedIsCI = builtins.trace "The value of CI environment variable is: ${toString isCI}" isCI;
        in
        rec {
          user = loggedUsername;
          fullName = "Alistair Stead";
          gitName = fullName;
          gitEmail = "62936+alistairstead@users.noreply.github.com";
          dotfilesRepo = "https://github.com/alistairstead/dotfiles2";
        };
      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in
    rec {
      # Contains my full Mac system builds, including home-manager
      # darwin-rebuild switch --flake .#wombat
      darwinConfigurations = {
        wombat = import ./hosts/wombat { inherit inputs globals; };
      };

      # For quickly applying home-manager settings with:
      # home-manager switch --flake .#wombat
      homeConfigurations = {
        wombat = darwinConfigurations.wombat.config.home-manager.users.${globals.user}.home;
      };

      # Programs that can be run by calling this flake
      apps = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        import ./apps { inherit pkgs; }
      );

      # Development environments
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {

          # Used to run commands and edit files in this repo
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
            ];
          };
        }
      );
    };
}


