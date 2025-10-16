#!/bin/bash

################################################################################
# macOS Developer Defaults Configuration
# 
# This script configures macOS system preferences optimized for development
# workflows in 2025. Settings are grouped by purpose for easy customization.
#
# Usage: ./macos-defaults.sh
#
# Note: Some changes require logging out or restarting Finder/Dock to take effect
# - Restart Finder: killall Finder
# - Restart Dock: killall Dock
################################################################################

set -x  # Echo commands for transparency

echo "🚀 Configuring macOS defaults for development..."

################################################################################
# FINDER SETTINGS
# Optimize file browsing and visibility for developers
################################################################################
echo "📁 Configuring Finder..."

# Show the ~/Library folder (essential for development)
chflags nohidden ~/Library

# Show hidden files and folders (dotfiles, .git, etc.)
defaults write com.apple.finder AppleShowAllFiles -bool true

# Display full POSIX path in Finder title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar at bottom of Finder windows
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar at bottom of Finder windows
defaults write com.apple.finder ShowPathbar -bool true

# Show icons for external drives and media on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Use list view in all Finder windows by default
# Other view modes: `icnv` (icon), `clmv` (column), `glyv` (gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Auto empty trash after 30 days
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

# Disable warning when changing file extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Disable warning when emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Enable spring loading for directories (hover to open)
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0.1

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

################################################################################
# DOCK & MISSION CONTROL
# Optimize workspace management and multitasking
################################################################################
echo "🎯 Configuring Dock & Mission Control..."

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Speed up the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0.5

# Set Dock icon sizes
defaults write com.apple.dock largesize -int 30
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock magnification -int 1

# Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool true

# Enable highlight hover effect for the grid view of a stack
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Show indicator lights for open applications
defaults write com.apple.dock show-process-indicators -bool true

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.15

# Don't group windows by application in Mission Control
defaults write com.apple.dock expose-group-by-app -bool false

# Displays have separate Spaces (useful for multi-monitor setups)
defaults write com.apple.spaces spans-displays -bool false

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

# Bottom right corner → Lock screen
defaults write com.apple.dock wvous-br-corner -int 13
defaults write com.apple.dock wvous-br-modifier -int 0

################################################################################
# TRACKPAD & INPUT
# Optimize input devices for productivity
################################################################################
echo "⌨️  Configuring Trackpad & Input..."

# Enable two-finger swipe for navigation (back/forward in browsers)
defaults write "Apple Global Domain" AppleEnableSwipeNavigateWithScrolls -int 1

# Four finger swipe to switch between workspaces
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2

# Set trackpad speed
defaults write -g com.apple.trackpad.scaling -float 0.875

# Disable "natural" scroll direction (better for developers)
defaults write -g com.apple.swipescrolldirection -bool false

# Enable tap to click for trackpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Set keyboard repeat rate to fast
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Enable full keyboard access for all controls (e.g., Tab in dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

################################################################################
# TEXT INPUT & AUTOCORRECT
# Disable features that interfere with coding
################################################################################
echo "✍️  Configuring Text Input..."

# Disable smart dashes (interferes with code)
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution (interferes with code)
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes (interferes with code)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

################################################################################
# SCREENSHOTS & MEDIA
# Organize and optimize media capture
################################################################################
echo "📸 Configuring Screenshots & Media..."

# Save screenshots to ~/screenshots folder
mkdir -p "$HOME/screenshots"
defaults write com.apple.screencapture location -string "$HOME/screenshots"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable screenshot shadow
defaults write com.apple.screencapture disable-shadow -bool true

# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2

################################################################################
# FILE DIALOGS & SAVE BEHAVIOR
# Optimize file operations for development
################################################################################
echo "💾 Configuring File Dialogs..."

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

################################################################################
# NETWORK & CONNECTIVITY
# Optimize network features for development
################################################################################
echo "🌐 Configuring Network..."

# Enable AirDrop over Ethernet and on unsupported Macs
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

################################################################################
# DEVELOPER-SPECIFIC SETTINGS
# Settings specifically useful for software development
################################################################################
echo "👨‍💻 Configuring Developer Settings..."

# Enable Safari's developer mode
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Show the ~/Library folder in Finder sidebar
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library 2>/dev/null

# Enable the debug menu in Address Book
defaults write com.apple.addressbook ABShowDebugMenu -bool true

# Enable Debug Menu in the Mac App Store
defaults write com.apple.appstore ShowDebugMenu -bool true

# Enable the WebKit Developer Tools in the Mac App Store
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

################################################################################
# PERFORMANCE & SYSTEM
# Optimize system performance for development
################################################################################
echo "⚡ Configuring Performance Settings..."

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable the sudden motion sensor (not needed for SSDs)
sudo pmset -a sms 0 2>/dev/null || true

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Disable animations when opening and closing windows
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Disable animations when opening a Quick Look window
defaults write -g QLPanelAnimationDuration -float 0

# Speed up dialog display
defaults write NSGlobalDomain NSWindowResizeTime -float 0.01

################################################################################
# SECURITY & PRIVACY
# Balance security with developer productivity
################################################################################
echo "🔒 Configuring Security & Privacy..."

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2>/dev/null || true

# Enable firewall stealth mode (don't respond to ICMP ping requests or connection attempts)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on 2>/dev/null || true

################################################################################
# TERMINAL & SHELL
# Optimize Terminal.app experience
################################################################################
echo "🖥️  Configuring Terminal..."

# Disable the line marks in Terminal.app
defaults write com.apple.Terminal ShowLineMarks -int 0

################################################################################
# CLEANUP & COMPLETION
################################################################################
echo ""
echo "✅ macOS defaults configured successfully!"
echo ""
echo "⚠️  Some changes require a restart to take effect:"
echo "   - Log out and log back in"
echo "   - Or restart your Mac"
echo ""
echo "To apply Finder and Dock changes immediately, run:"
echo "   killall Finder"
echo "   killall Dock"
echo ""