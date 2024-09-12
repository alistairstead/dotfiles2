{
  description = "My system flake";

  inputs = {
    # Used for system packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    # Used for specific stable packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Pin the pkgs for darwin and home-manager to the same commit
    # this commit has a working version of swift for darwin
    darwin-nixpkgs.url = "github:nixos/nixpkgs?rev=2e92235aa591abc613504fde2546d6f78b18c0cd";

    # Used for MacOS system config
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "darwin-nixpkgs";
    };

    # Used for user packages and dotfiles
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list for their inputs
    };

    # Better App install management in macOS
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list for their inputs
    };
  };

  outputs = inputs@{ nixpkgs, ... }:
    let
      # Global configuration for my systems
      globals =
        let
          envUsername = builtins.getEnv "USERNAME";
          username = if envUsername == "" then "alistairstead" else envUsername;
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

      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          neovim =
            pkgs.runCommand "neovim-check-health" { buildInputs = [ inputs.self.packages.${system}.neovim ]; }
              ''
                mkdir -p $out
                export HOME=$TMPDIR
                nvim -c "checkhealth" -c "write $out/health.log" -c "quitall"

                # Check for errors inside the health log
                if $(grep "ERROR" $out/health.log); then
                  cat $out/health.log
                  exit 1
                fi
              '';
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.nixfmt-rfc-style
      );
    };
}


