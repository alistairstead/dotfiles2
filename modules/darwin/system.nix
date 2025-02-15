{ pkgs
, lib
, ...
}:
{

  config = lib.mkIf pkgs.stdenv.isDarwin {

    services.nix-daemon.enable = true;

    # This setting only applies to Darwin, different on NixOS
    nix.gc.interval = {
      Hour = 12;
      Minute = 15;
      Day = 1;
    };

    environment.shells = with pkgs; [ 
      bash
      fish 
      zsh
    ];

    security.pam.enableSudoTouchIdAuth = true;
    security.pam.enablePamReattach = true;

    system = {
      startup = {
        chime = false;
      };
      keyboard = {
        remapCapsLockToControl = true;
        enableKeyMapping = true; # Allows for skhd
      };

      defaults = {

        loginwindow = {
          # Text to be shown on the login window. Default is “\\U03bb”.
          LoginwindowText = "Reward available for return call +44 (0)7788 107333";
        };

        NSGlobalDomain = {

          # Set to dark mode
          AppleInterfaceStyle = "Dark";

          # Don't change from dark to light automatically
          AppleInterfaceStyleSwitchesAutomatically = false;

          # Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
          AppleKeyboardUIMode = 3;

          # Hide menu bar
          _HIHideMenuBar = true;

          # Expand save panel by default
          NSNavPanelExpandedStateForSaveMode = true;

          # Expand print panel by default
          PMPrintingExpandedStateForPrint = true;

          # Replace press-and-hold with key repeat
          ApplePressAndHoldEnabled = false;

          # Set a fast key repeat rate
          # KeyRepeat: 120, 90, 60, 30, 12, 6, 2
          KeyRepeat = 2;

          # Shorten delay before key repeat begins
          # InitialKeyRepeat: 120, 94, 68, 35, 25, 15
          InitialKeyRepeat = 15;

          # Save to iCLoud by default, not local disk
          NSDocumentSaveNewDocumentsToCloud = true;

          # Disable autocorrect capitalization
          NSAutomaticCapitalizationEnabled = false;

          # Disable autocorrect smart dashes
          NSAutomaticDashSubstitutionEnabled = false;

          # Disable autocorrect adding periods
          NSAutomaticPeriodSubstitutionEnabled = false;

          # Disable autocorrect smart quotation marks
          NSAutomaticQuoteSubstitutionEnabled = false;

          # Disable autocorrect spellcheck
          NSAutomaticSpellingCorrectionEnabled = false;

          "com.apple.springing.enabled" = true;
        };

        dock = {
          # Automatically show and hide the dock
          autohide = true;

          # Add translucency in dock for hidden applications
          showhidden = true;

          # Enable spring loading on all dock items
          enable-spring-load-actions-on-all-items = true;

          # Highlight hover effect in dock stack grid view
          mouse-over-hilite-stack = true;

          # Set the minimize/maximize window effect. The default is genie.
          # mineffect = "scale";

          orientation = "bottom";
          # Animate opening applications from the Dock. The default is true.
          launchanim = false;

          show-recents = false;
          tilesize = 44;

          persistent-apps = [
            "/Applications/1Password.app"
            "${pkgs.slack}/Applications/Slack.app"
            "/System/Applications/Messages.app"
            "${pkgs.obsidian}/Applications/Obsidian.app"
            "${pkgs.wezterm}/Applications/WezTerm.app"
          ];
        };

        finder = {
          # Whether to always show hidden files. The default is false.
          AppleShowAllFiles = true;

          # Default Finder window set to column view
          # Change the default finder view. “icnv” = Icon view, “Nlsv” = List view, 
          # “clmv” = Column View, “Flwv” = Gallery View The default is icnv.
          FXPreferredViewStyle = "clmv";

          # Finder search in current folder by default
          FXDefaultSearchScope = "SCcf";

          # Disable warning when changing file extension
          FXEnableExtensionChangeWarning = false;

          # Allow quitting of Finder application
          QuitMenuItem = true;

          # Show path breadcrumbs in finder windows. The default is false.
          ShowPathbar = true;

          # Show status bar at bottom of finder windows with item/disk space stats. The default is false.
          ShowStatusBar = true;
        };

        # Disable "Are you sure you want to open" dialog
        LaunchServices.LSQuarantine = false;

        # Enable trackpad tap to click
        trackpad.Clicking = true;

        # Where to save screenshots
        screencapture.location = "~/Downloads";

        CustomUserPreferences = {
          # Disable disk image verification
          "com.apple.frameworks.diskimages" = {
            skip-verify = true;
            skip-verify-locked = true;
            skip-verify-remote = true;
          };
          # Avoid creating .DS_Store files on network or USB volumes
          "com.apple.desktopservices" = {
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };
          "com.apple.dock" = {
            magnification = true;
            largesize = 48;
          };
          # Require password immediately after screen saver begins
          "com.apple.screensaver" = {
            askForPassword = 1;
            askForPasswordDelay = 0;
          };
          "com.apple.finder" = {
            # Disable the warning before emptying the Trash
            WarnOnEmptyTrash = false;

            # Finder search in current folder by default
            FXDefaultSearchScope = "SCcf";

            # Default Finder window set to column view
            FXPreferredViewStyle = "clmv";
          };
        };
      };

    };
  };
}
