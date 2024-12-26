#!/bin/bash

# setup mac's name
sudo scutil --set ComputerName fernando
sudo scutil --set LocalHostName fernando
sudo scutil --set HostName fernando

echo "Installing x-code"
xcode-select --install

if test ! $(which brew); then
    echo "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Updating homebrew"
brew update

echo "Installing Git"
brew install git

echo "Creating projects folder"
mkdir ~/projects

echo "Cloning dotfiles"
git clone https://github.com/fernandoflorez/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
git submodule update --init

echo "Installing Brewfile"
brew bundle

stow --target $HOME alacritty git gnupg tmux zsh nvim aerospace bat ghostty
bat cache --build

# set permissions to gnupg
chown -R $(whoami) ~/.config/gnupg/
find ~/.config/gnupg -type f -exec chmod 600 {} \;
find ~/.config/gnupg -type d -exec chmod 700 {} \;

echo "starting tmux"
if ! { [ -n "$TMUX" ]; } then
    tmux
fi

echo "Cleaning up brew"
brew cleanup

echo "Mac OS customization"

# do not create .DS_Store
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

# speedy wake up to 24 hours
sudo pmset -a standbydelay 86400

# Show battery percentage
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -int 1

# Display bluetooth icon on menubar
defaults -currentHost write com.apple.controlcenter Bluetooth -int 2

# Disabling system-wide resume
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Right click on two finger tap
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

# Disabling OS X Gate Keeper
# (You'll be able to install any app you want from here on, not just Mac App Store apps)
sudo spctl --master-disable
sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Saving to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Expanding the save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Avoiding the creation of .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Setting the icon size of Dock items to 23 pixels for optimal size/screen-realestate
defaults write com.apple.dock tilesize -int 23

# Dock: position the Dock on the left
defaults write com.apple.dock orientation left

# Dock: Only have appstore and system preferences on dock
defaults write com.apple.dock persistent-apps -array
for item in /System/Applications/{"App Store","System Settings"}.app; do
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$item</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
done

# Finder: empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Enable trackpad tap to click
defaults write com.apple.AppleBluetoothMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Set mouse and trackpad speed
defaults write -g com.apple.trackpad.scaling 3
defaults write -g com.apple.mouse.scaling 3

# Display 24 hour clock and date
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  HH:mm"

# set default screensaver
defaults -currentHost write com.apple.screensaver moduleDict -dict moduleName Fliqlo path /Users/fernando/Library/Screen\ Savers/Fliqlo.saver

# Prevent Time Machine from prompting to use new hard drive as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Save screenshots on Downloads folder and do not display screenshot previews
defaults write com.apple.screencapture location ~/Downloads
defaults write com.apple.screencapture show-thumbnail -bool FALSE

killall Finder
killall Dock
killall SystemUIServer

echo "Done"
