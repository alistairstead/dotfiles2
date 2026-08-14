#!/bin/bash
#
# `defaults` and `sudo` are shadowed by shell functions under --dry-run, which
# ShellCheck reads as passing a function to an external command. In a real run
# they are the ordinary commands.
# shellcheck disable=SC2033
#
# macOS System Setup Script
#
# Usage: macos-setup.sh [--dry-run]
#   --dry-run  Print what would change, current value to proposed value, and
#              write nothing. Also accepted as DRY_RUN=1.

set -e

DRY_RUN=${DRY_RUN:-}
DRY_VERBOSE=${DRY_VERBOSE:-}

case "${1:-}" in
    -n | --dry-run)
        DRY_RUN=1
        [ "${2:-}" = "--verbose" ] && DRY_VERBOSE=1
        ;;
    --verbose)
        DRY_RUN=1
        DRY_VERBOSE=1
        ;;
    -h | --help)
        cat <<'USAGE'
Usage: macos-setup.sh [--dry-run [--verbose]]

  --dry-run, -n  Show what would change and write nothing. Lines are marked
                 ~ changed, + new, ! other command. Already-correct settings
                 are counted, not listed.
  --verbose      With --dry-run, also list settings already at the wanted
                 value.

Environment: DRY_RUN=1 and DRY_VERBOSE=1 do the same.
USAGE
        exit 0
        ;;
    "") ;;
    *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
esac

if [ -n "$DRY_RUN" ]; then
    DRY_CHANGED=0
    DRY_ADDED=0
    DRY_SAME=0

    # `defaults write` takes a type flag; `defaults read` prints a bare value.
    # Normalise the proposed value into what read would print, so the two can
    # be compared rather than just listed.
    _dry_normalise() {
        case "${1:-}" in
            -bool | -boolean)
                case "${2:-}" in
                    true | TRUE | yes | YES | 1) echo 1 ;;
                    *) echo 0 ;;
                esac
                ;;
            -int | -integer | -float | -string)
                shift
                echo "$*"
                ;;
            *) echo "$*" ;;
        esac
    }

    _dry_write() {
        local domain=$1 key=$2 proposed current
        shift 2
        proposed=$(_dry_normalise "$@")

        if current=$(command defaults read "$domain" "$key" 2>/dev/null); then
            # Arrays and dicts read back multi-line; keep the diff to one line
            current=$(echo "$current" | tr '\n' ' ' | sed 's/  */ /g; s/ $//')
            if [ "$current" = "$proposed" ]; then
                DRY_SAME=$((DRY_SAME + 1))
                if [ -n "$DRY_VERBOSE" ]; then
                    printf '    %s %s = %s (already set)\n' "$domain" "$key" "$current"
                fi
            else
                DRY_CHANGED=$((DRY_CHANGED + 1))
                printf '  ~ %s %s: %s -> %s\n' "$domain" "$key" "$current" "$proposed"
            fi
        else
            DRY_ADDED=$((DRY_ADDED + 1))
            printf '  + %s %s = %s\n' "$domain" "$key" "$proposed"
        fi
    }

    # Nothing here reads defaults for control flow, so shimming the mutating
    # commands is enough to make the whole script inert. `command` bypasses
    # the shim where the real thing is still wanted.
    defaults() {
        if [ "${1:-}" != "write" ]; then
            command defaults "$@"
            return
        fi
        shift
        _dry_write "$@"
    }

    sudo() {
        # sudo defaults write ... is still a defaults write; the plists under
        # /Library/Preferences are readable without privileges
        if [ "${1:-}" = "defaults" ] && [ "${2:-}" = "write" ]; then
            shift 2
            _dry_write "$@"
        else
            printf '  ! would run: sudo %s\n' "$*"
        fi
    }

    killall() { printf '  ! would run: killall %s\n' "$*"; }
    mkdir() { printf '  ! would run: mkdir %s\n' "$*"; }

    dry_run_summary() {
        echo ""
        echo "Dry run summary: $DRY_CHANGED changed, $DRY_ADDED new, $DRY_SAME already set"
        if [ -z "$DRY_VERBOSE" ] && [ "$DRY_SAME" -gt 0 ]; then
            echo "Re-run with --verbose to see the $DRY_SAME already at the wanted value."
        fi
    }
    trap dry_run_summary EXIT

    echo "DRY RUN: nothing will be written"
    echo "  ~ changes an existing value   + sets a new one   ! other command"
    echo ""
fi

# Machine-local values that should not live in a public repo, e.g.
# LOGIN_WINDOW_TEXT. Optional.
if [ -r "$HOME/private/macos-setup.env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/private/macos-setup.env"
fi

echo "Setting up macOS system preferences..."

# Enable Touch ID for sudo (if not already enabled)
setup_touchid_sudo() {
    echo "Configuring Touch ID for sudo..."
    
    # Check if Touch ID is already enabled
    if ! grep -q "pam_tid.so" /etc/pam.d/sudo_local 2>/dev/null; then
        # Create sudo_local file with Touch ID support
        sudo tee /etc/pam.d/sudo_local > /dev/null <<EOF
# sudo_local: local config for sudo to enable Touch ID
auth       sufficient     pam_tid.so
auth       include        sudo
account    include        sudo
password   include        sudo
session    include        sudo
EOF
        echo "✓ Touch ID enabled for sudo"
    else
        echo "✓ Touch ID already enabled for sudo"
    fi
}

# Set Homebrew environment variables
setup_homebrew_env() {
    # HOMEBREW_NO_ANALYTICS is exported from shell/.config/shell/env.sh.
    # Appending it to ~/.zshenv here wrote through the stow symlink and into
    # the repo.
    echo "Homebrew environment comes from ~/.config/shell/env.sh"
}

# Link MySQL client (if installed)
link_mysql_client() {
    if [ -x "/opt/homebrew/bin/brew" ] && /opt/homebrew/bin/brew list mysql-client@8.4 &>/dev/null; then
        echo "Linking MySQL client..."
        # Full path, so the dry-run shims do not cover it
        if [ -n "$DRY_RUN" ]; then
            echo "    would run: brew link --overwrite --force mysql-client@8.4"
        else
            /opt/homebrew/bin/brew link --overwrite --force mysql-client@8.4
        fi
    fi
}

# Configure macOS system defaults
setup_system_defaults() {
    echo "Configuring system defaults..."
    
    # Disable "Are you sure you want to open" dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    
    # Set accent color (blue)
    defaults write NSGlobalDomain AppleAccentColor -int 4
    
    # Enable dark mode
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
    
    # Disable automatic interface style switching
    defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool false
    
    # Disable guest account login
    sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
    
    # Set login window text. The message is normally a personal phone number
    # and this repo is public, so it is not hardcoded here. Set
    # LOGIN_WINDOW_TEXT in ~/private/macos-setup.env to manage it; without
    # that, whatever is already on the machine is left alone.
    if [ -n "${LOGIN_WINDOW_TEXT:-}" ]; then
        sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText -string "$LOGIN_WINDOW_TEXT"
    else
        echo "  (login window text unmanaged; set LOGIN_WINDOW_TEXT to change it)"
    fi
    
    # Disable system startup chime
    sudo nvram SystemAudioVolume=" "
    
    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    
    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    
    # Automatically quit printer app once the print jobs complete
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
    
    # There used to be an lsregister -kill -r -domain ... call here to rebuild
    # the "Open With" menu. macOS removed -kill ("dangerous and no longer
    # useful") and -domain is not an option either, so the command now exits
    # non-zero and, under set -e, took every setup step below it with it.

    # Disable automatic termination of inactive apps
    defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true
    
    # Reveal system info when clicking the clock in the login window
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
    
    # Disable window animations and reduce motion
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
    
    # Keep default highlight color (using accent color)
    
    echo "✓ System defaults configured"
}

# Configure keyboard settings
setup_keyboard() {
    echo "Configuring keyboard settings..."
    
    # Remap Caps Lock to Control
    # Note: This requires a logout/login to take effect
    hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}' > /dev/null
    
    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    
    # Set fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    
    # Set short delay until key repeat
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Enable full keyboard access for all controls
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    
    # Set language and locale
    defaults write NSGlobalDomain AppleLanguages -array "en-GB" "en"
    defaults write NSGlobalDomain AppleLocale -string "en_GB@currency=GBP"
    defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
    defaults write NSGlobalDomain AppleMetricUnits -bool true
    
    # Set timezone
    sudo systemsetup -settimezone "Europe/London" > /dev/null
    
    echo "✓ Keyboard settings configured"
}

# Configure trackpad settings
setup_trackpad() {
    echo "Configuring trackpad settings..."
    
    # Enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    # Map bottom right corner to right-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
    
    # Enable "natural" scrolling
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true
    
    # Increase Bluetooth audio quality
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
    
    echo "✓ Trackpad settings configured"
}

# Configure Finder settings
setup_finder() {
    echo "Configuring Finder settings..."
    
    # Allow quitting Finder via ⌘ + Q
    defaults write com.apple.finder QuitMenuItem -bool true
    
    # Show all file extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Disable desktop creation
    defaults write com.apple.finder CreateDesktop -bool false
    
    # Use column view as default
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
    
    # Disable file extension change warning
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    
    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # Show POSIX path in title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    
    # Disable all animations
    defaults write com.apple.finder DisableAllAnimations -bool true
    
    # Don't show external drives on desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
    
    # Set Desktop as the default location for new Finder windows
    defaults write com.apple.finder NewWindowTarget -string "PfDe"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"
    
    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    
    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false
    
    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    
    # Disable disk image verification
    defaults write com.apple.frameworks.diskimages skip-verify -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
    
    # Automatically open a new Finder window when a volume is mounted
    defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
    defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
    defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
    
    # Restart Finder
    killall Finder || true
    
    echo "✓ Finder settings configured"
}

# Configure Dock settings
setup_dock() {
    echo "Configuring Dock settings..."
    
    # Enable spring loading for all Dock items
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
    
    # Disable launch animations
    defaults write com.apple.dock launchanim -bool false
    
    # Enable auto-hide
    defaults write com.apple.dock autohide -bool true
    
    # Remove dock show delay
    defaults write com.apple.dock autohide-delay -float 0
    
    # Set dock position to bottom
    defaults write com.apple.dock orientation -string "bottom"
    
    # Don't show recent apps
    defaults write com.apple.dock show-recents -bool false
    
    # Set tile size
    defaults write com.apple.dock tilesize -int 50
    
    # Enable the hover effect for the grid view of a stack
    defaults write com.apple.dock mouse-over-hilite-stack -bool true
    
    # Minimize windows into their application's icon
    defaults write com.apple.dock minimize-to-application -bool true
    
    # Show only open applications in the Dock
    defaults write com.apple.dock static-only -bool true
    
    # Disable Dashboard
    defaults write com.apple.dashboard mcx-disabled -bool true
    
    # Don't show Dashboard as a Space
    defaults write com.apple.dock dashboard-in-overlay -bool true
    
    # Make Dock icons of hidden applications translucent
    defaults write com.apple.dock showhidden -bool true
    
    # Clear existing dock items (optional - commented out for safety)
    # defaults write com.apple.dock persistent-apps -array
    
    # Add specific apps to dock (optional - customize as needed)
    # Note: This is more complex and requires specific app paths
    
    # Restart Dock
    killall Dock || true
    
    echo "✓ Dock settings configured"
}

# Configure screenshot settings
setup_screenshots() {
    echo "Configuring screenshot settings..."
    
    # Create screenshots directory
    mkdir -p ~/Pictures/screenshots
    
    # Set screenshot location
    defaults write com.apple.screencapture location -string "$HOME/Pictures/screenshots"
    
    # Set screenshot format to PNG
    defaults write com.apple.screencapture type -string "png"
    
    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true
    
    echo "✓ Screenshot settings configured"
}

# Configure screen and display settings
setup_screen() {
    echo "Configuring screen settings..."
    
    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    
    # Enable subpixel font rendering on non-Apple LCDs
    defaults write NSGlobalDomain AppleFontSmoothing -int 2
    
    # Enable HiDPI display modes (requires restart)
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true
    
    echo "✓ Screen settings configured"
}

# Configure Mac App Store and software update settings
setup_app_store() {
    echo "Configuring App Store settings..."
    
    # Enable the WebKit Developer Tools in the Mac App Store
    defaults write com.apple.appstore WebKitDeveloperExtras -bool true
    
    # Enable Debug Menu in the Mac App Store
    defaults write com.apple.appstore ShowDebugMenu -bool true
    
    # Enable automatic update check
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
    
    # Check for software updates daily, not just once per week
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
    
    # Download newly available updates in background
    defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
    
    # Install System data files & security updates
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
    
    # Turn on app auto-update
    defaults write com.apple.commerce AutoUpdate -bool true
    
    # Allow the App Store to reboot machine on macOS updates
    defaults write com.apple.commerce AutoUpdateRestartRequired -bool true
    
    echo "✓ App Store settings configured"
}

# Configure application-specific settings
setup_applications() {
    echo "Configuring application-specific settings..."

    # Keep font smoothing on globally
    defaults write -g CGFontRenderingFontSmoothingDisabled -bool false

    echo "✓ Application settings configured"
}

# Main execution
main() {
    echo "Starting macOS system setup..."
    
    if [ -z "$DRY_RUN" ]; then
        # Request sudo access upfront, then keep it alive
        sudo -v
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi

    setup_touchid_sudo
    setup_homebrew_env
    link_mysql_client
    setup_system_defaults
    setup_keyboard
    setup_trackpad
    setup_finder
    setup_dock
    setup_screenshots
    setup_screen
    setup_app_store
    setup_applications
    
    echo ""
    echo "✓ macOS system setup complete!"
    echo ""
    echo "Note: Some changes require a logout/restart to take effect:"
    echo "  - Caps Lock → Control remapping"
    echo "  - Some Finder settings"
    echo "  - HiDPI display modes"
    echo "  - Language and locale changes"
    echo ""
    echo "You may want to restart your computer now."
}

main "$@"