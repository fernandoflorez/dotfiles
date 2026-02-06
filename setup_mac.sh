#!/bin/bash

set -e

# setup mac's name
sudo scutil --set ComputerName fernando
sudo scutil --set LocalHostName fernando
sudo scutil --set HostName fernando

if ! xcode-select -p &>/dev/null; then
    echo "Installing xcode command line tools"
    xcode-select --install
    echo "Press any key after xcode tools installation is complete"
    read -n 1 -s
fi

if ! command -v brew &>/dev/null; then
    echo "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Updating homebrew"
brew update

echo "Installing Brewfile"
brew bundle --file=~/projects/dotfiles/Brewfile

mkdir -p ~/projects

if [ ! -d ~/projects/dotfiles ]; then
    echo "Cloning dotfiles"
    git clone https://github.com/fernandoflorez/dotfiles.git ~/projects/dotfiles
fi

cd ~/projects/dotfiles
git submodule update --init

stow --target $HOME git gnupg tmux zsh nvim aerospace bat ghostty ssh starship
bat cache --build

# set permissions to gnupg
if [ -d ~/.config/gnupg ]; then
    chown -R $(whoami) ~/.config/gnupg/
    find ~/.config/gnupg -type f -exec chmod 600 {} \;
    find ~/.config/gnupg -type d -exec chmod 700 {} \;
fi

echo "Cleaning up brew"
brew cleanup

if [ -z "$TMUX" ]; then
    echo "Starting tmux"
    tmux
fi

echo "Mac OS customization"

# Set standby delay to 24 hours (faster wake from sleep)
sudo pmset -a standbydelay 86400

# Show battery percentage
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -int 1

# Display bluetooth icon on menubar
defaults -currentHost write com.apple.controlcenter Bluetooth -int 2

# Disable system-wide resume (do not reopen windows when quitting apps)
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Saving to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Expand save and print panels by default (show full dialog instead of compact)
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2

# Short delay before key repeat starts
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Finder: default view as list
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder: search in current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Avoiding the creation of .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Setting the icon size of Dock items to 16 pixels for optimal size/screen-realestate
defaults write com.apple.dock tilesize -int 16

# Dock: autohide
defaults write com.apple.dock autohide -bool true

# Dock: position the Dock on the left
defaults write com.apple.dock orientation left

# Dock: Only have appstore and system preferences on dock
defaults write com.apple.dock persistent-apps -array
for item in /System/Applications/{"App Store","System Settings"}.app; do
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$item</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
done

# Enable trackpad tap to click
defaults write com.apple.AppleBluetoothMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable Force Click
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool true
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false

# Light click sensitivity
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0

# Right click on two finger tap
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

# Scroll speed
defaults write -g com.apple.scrollwheel.scaling -float 1.7

# Double click threshold
defaults write -g com.apple.mouse.doubleClickThreshold -float 0.8

# Set mouse and trackpad speed
defaults write -g com.apple.trackpad.scaling 3
defaults write -g com.apple.mouse.scaling 3

# Safari: enable Develop menu
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "WebKitPreferences.developerExtrasEnabled" -bool true

# Safari: require authentication for private browsing
defaults write com.apple.Safari PrivateBrowsingRequiresAuthentication -bool true

# Hide desktop icons when clicking on a window
defaults write com.apple.WindowManager HideDesktop -bool true
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true

# Hide desktop widgets
defaults write com.apple.WindowManager StandardHideWidgets -bool true
defaults write com.apple.WindowManager StageManagerHideWidgets -bool true

# No margins between tiled windows
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# Hide Sound icon from menu bar
defaults -currentHost write com.apple.controlcenter Sound -int 8

# Hide Now Playing from menu bar
defaults -currentHost write com.apple.controlcenter NowPlaying -int 8

# Hide Spotlight from menu bar
defaults -currentHost write com.apple.controlcenter Spotlight -int 8

# Auto switch between light and dark mode
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# Disable swipe navigation
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false

# Do not minimize on double click title bar
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false

# Display 24 hour clock and date
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  HH:mm"

# Prevent Time Machine from prompting to use new hard drive as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Save screenshots on Downloads folder and do not display screenshot previews
defaults write com.apple.screencapture location ~/Downloads
defaults write com.apple.screencapture show-thumbnail -bool FALSE

# Do not restore windows on restart
defaults write com.apple.loginwindow TALLogoutSavesState -bool false

killall Finder
killall Dock
killall SystemUIServer
killall ControlCenter

echo "Done"
