{ config
, pkgs
, lib
, ...
}:
{

  # Homebrew - Mac-specific packages that aren't in Nix
  config = lib.mkIf pkgs.stdenv.isDarwin {

    # Requires Homebrew to be installed
    system.activationScripts.preUserActivation.text = ''
      if ! xcode-select --version 2>/dev/null; then
        $DRY_RUN_CMD xcode-select --install
      fi
      if ! /opt/homebrew/bin/brew --version 2>/dev/null; then
        $DRY_RUN_CMD /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    '';

    # Add homebrew paths to CLI path
    home-manager.users.${config.user}.home.sessionPath = [ "/opt/homebrew/bin/"  ];

    environment.systemPath = [ "/opt/homebrew/bin" ];

    environment.variables = {
      HOMEBREW_NO_ANALYTICS = "1";
    };

    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "zap"; # Uninstall all programs not declared
        upgrade = true;
      };
      global = {
        brewfile = true; # Run brew bundle from anywhere
        lockfiles = false; # Don't save lockfile (since running from anywhere)
      };
      taps = [
        "1password/tap"
        "neovim/neovim"
      ];
      brews = [
        "trash" # Delete files and folders to trash instead of rm
        "lazydocker" # Docker in a terminal
        "neovim"
      ];
      casks = [
        "1password" # 1Password will not launch from Nix on macOS
        "1password-cli" # 1Password CLI
        "around" # Around - Video calls
        "bartender"
        "choosy" # Choose browser
        "cleanmymac" # Clean up macOS
        "cleanshot" # screen shots sorted
        "figma"
        "font-symbols-only-nerd-font" # Nerd Font with only symbols
        "google-chrome" # Chrome
        "home-assistant" # Home Assistant
        "nordvpn"
        "orbstack"
        "readdle-spark"
        "sizzy"
        "todoist"
      ];
      caskArgs = {
        appdir = "/Applications";
      };
      # This requires a prior login to the App Store so will not
      # run on CI
      # masApps = {
      #   "1Password for Safari" = 1569813296;
      # };
    };
  };
}
