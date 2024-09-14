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
    home-manager.users.${config.user}.home.sessionPath = [ "/opt/homebrew/bin/" ];

    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = false; # Don't update during rebuild
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
        "neovim"
      ];
      casks = [
        "1password" # 1Password will not launch from Nix on macOS
        "1password-cli" # 1Password CLI
        "meetingbar" # Show meetings in menu bar
        "steam" # Not packaged for Nixon macOS
        "font-symbols-only-nerd-font" # Nerd Font with only symbols
        "cleanmymac" # Clean up macOS
        # "cleanshot" # screen shots sorted
        "choosy" # Choose browser
        "google-chrome" # Chrome
      ];
    };
  };
}
