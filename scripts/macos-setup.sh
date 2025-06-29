#!/bin/bash
# macOS System Setup Script

set -e

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
    echo "Setting Homebrew environment..."
    export HOMEBREW_NO_ANALYTICS=1
    
    # Add to shell profile if not already present
    if ! grep -q "HOMEBREW_NO_ANALYTICS" ~/.zshenv 2>/dev/null; then
        echo "export HOMEBREW_NO_ANALYTICS=1" >> ~/.zshenv
    fi
}

# Link MySQL client (if installed)
link_mysql_client() {
    if [ -x "/opt/homebrew/bin/brew" ] && /opt/homebrew/bin/brew list mysql-client@8.4 &>/dev/null; then
        echo "Linking MySQL client..."
        /opt/homebrew/bin/brew link --overwrite --force mysql-client@8.4
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
    
    # Set login window text
    sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText -string "Found this computer? Please call +1 (415) 935-3547"
    
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
    
    # Remove duplicates in the "Open With" menu
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
    
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
    
    # Disable font smoothing for Alacritty
    defaults write -g CGFontRenderingFontSmoothingDisabled -bool false
    defaults write org.alacritty AppleFontSmoothing -int 0
    
    echo "✓ Application settings configured"
}

# Main execution
main() {
    echo "Starting macOS system setup..."
    
    # Request sudo access upfront
    sudo -v
    
    # Keep sudo alive
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    
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