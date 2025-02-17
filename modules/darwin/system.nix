{ pkgs, lib , ... }: {
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
        # Disable "Are you sure you want to open" dialog
        LaunchServices.LSQuarantine = false;

        # Enable trackpad tap to click
        trackpad.Clicking = true;
        CustomSystemPreferences = {
          finder = {
            DisableAllAnimations = true;
            ShowExternalHardDrivesOnDesktop = false;
            ShowHardDrivesOnDesktop = false;
            ShowMountedServersOnDesktop = false;
            ShowRemovableMediaOnDesktop = false;
            _FXSortFoldersFirst = true;
          };

          NSGlobalDomain = {
            AppleAccentColor = 1;
            AppleHighlightColor = "0.65098 0.85490 0.58431";
            AppleSpacesSwitchOnActivate = true;
            WebKitDeveloperExtras = true;
            AppleFontSmoothing = 1;
          };
        };

        # login window settings
        loginwindow = {
          # disable guest account
          GuestEnabled = false;
          # show name instead of username
          SHOWFULLNAME = false;
          LoginwindowText = "Reward available for return call +44 (0)7788 107333";
        };

        # file viewer settings
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          CreateDesktop = false;
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          # NOTE: Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
          FXPreferredViewStyle = "clmv";
          QuitMenuItem = true;
          ShowStatusBar = true;
          _FXShowPosixPathInTitle = true;
        };

        # dock settings
        dock = {
          # Enable spring loading on all dock items
          enable-spring-load-actions-on-all-items = true;
          # Animate opening applications from the Dock. The default is true.
          launchanim = false;
          # auto show and hide dock
          autohide = true;
          # remove delay for showing dock
          autohide-delay = 0.0;
          # how fast is the dock showing animation
          autohide-time-modifier = 1.0;
          mineffect = "scale";
          minimize-to-application = true;
          mouse-over-hilite-stack = true;
          mru-spaces = false;
          orientation = "bottom";
          show-process-indicators = true;
          show-recents = false;
          showhidden = false;
          static-only = false;
          tilesize = 50;

          # Hot corners
          # Possible values:
          #  0: no-op
          #  2: Mission Control
          #  3: Show application windows
          #  4: Desktop
          #  5: Start screen saver
          #  6: Disable screen saver
          #  7: Dashboard
          # 10: Put display to sleep
          # 11: Launchpad
          # 12: Notification Center
          # 13: Lock Screen
          # 14: Quick Notes
          wvous-tl-corner = 0;
          wvous-tr-corner = 0;
          wvous-bl-corner = 0;
          wvous-br-corner = 0;

          # sudo su "$USER" -c "defaults write com.apple.dock persistent-apps -array 	\
          # '$launchpad' '$settings' '$appstore' '$small_blank' 																		\
          # '$messages' '$messenger' '$teams' '$discord' '$mail' '$small_blank' 										\
          # '$firefox' '$safari' '$fantastical' '$reminders' '$notes' '$small_blank' 								\
          # '$music' '$spotify' '$plex' '$small_blank' 																							\
          # '$code' '$github' '$gitkraken' '$small_blank' 													\
          # '$alacritty' '$kitty'"
          persistent-apps = [
            "/System/Applications/System Settings.app"
            "/System/Applications/App Store.app"
            "/Applications/Safari.app"
            "/System/Applications/Music.app"
          ];
        };

        screencapture = {
          disable-shadow = true;
          location = "$HOME/Pictures/screenshots/";
          type = "png";
        };

        NSGlobalDomain = {
          "com.apple.sound.beep.feedback" = 0;
          "com.apple.sound.beep.volume" = 0.0;
          AppleShowAllExtensions = true;
          AppleShowScrollBars = "Automatic";
          NSAutomaticWindowAnimationsEnabled = false;
          _HIHideMenuBar = true;
          # Set to dark mode
          AppleInterfaceStyle = "Dark";
          # Don't change from dark to light automatically
          AppleInterfaceStyleSwitchesAutomatically = false;
          # Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
          AppleKeyboardUIMode = 3;
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
      };
    };
  };
}
