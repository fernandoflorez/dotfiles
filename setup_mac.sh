#!/bin/bash

# setup mac's name
sudo scutil --set ComputerName fernando
sudo scutil --set LocalHostName fernando
sudo scutil --set HostName fernando

echo "Installing x-code"
xcode-select --install

if test ! $(which brew); then
    echo "Installing homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Updating homebrew"
brew update

echo "Installing Git"
brew install git

echo "Git config"
git config --global user.name "Fernando Flórez"
git config --global user.email "fernando@funciton.com"
git config --global core.excludesfile ~/projects/dotfiles/gitignore_global

echo "Creating projects folder"
mkdir ~/projects

echo "Cloning dotfiles"
mkdir ~/projects/dotfiles
cd ~/projects/dotfiles
git clone https://github.com/fernandoflorez/dotfiles.git .

echo "Installing Brewfile"
brew bundle

echo "Config cloudflared"
mkdir -p /usr/local/etc/cloudflared
cat << EOF > /usr/local/etc/cloudflared/config.yml
proxy-dns: true
proxy-dns-upstream:
 - https://1.1.1.1/dns-query
 - https://1.0.0.1/dns-query
EOF
networksetup -setdnsservers Wi-Fi 127.0.0.1

echo "Installing GAM"
bash <(curl -s -S -L https://git.io/install-gam)

echo "Installing v"
curl -fsSl https://raw.githubusercontent.com/fernandoflorez/v/master/setup.sh | bash

echo "Creating dotfile links"
ln -s ~/projects/dotfiles/bashrc ~/.bashrc
ln -s ~/projects/dotfiles/zshrc ~/.zshrc
ln -s ~/projects/dotfiles/profile ~/.profile
ln -s ~/.v/v/vimrc ~/.vimrc
ln -s ~/projects/dotfiles/vimrc.after ~/.vimrc.after
ln -s ~/projects/dotfiles/vimrc.before ~/.vimrc.before

echo "setup gnupg"
mkdir ~/.gnupg
chown -R $(whoami) ~/.gnupg/
find ~/.gnupg -type f -exec chmod 600 {} \;
find ~/.gnupg -type d -exec chmod 700 {} \;
ln -s ~/projects/dotfiles/gpg-agent.conf ~ /.gnupg/gpg-agent.conf

echo "Cleaning up brew"
brew cleanup

echo "Mac OS customization"

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent YES

# Disabling system-wide resume
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

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

# Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate
defaults write com.apple.dock tilesize -int 36

# Dock: position the Dock on the left
defaults write com.apple.dock orientation left

# Finder: empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Dark menu bar and dock
defaults write $HOME/Library/Preferences/.GlobalPreferences.plist AppleInterfaceTheme -string "Dark"

# Enable trackpad tap to click
defaults write com.apple.AppleBluetoothMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Display 24 hour clock and date
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  HH:mm"

killall Finder
killall Dock
killall SystemUIServer

echo "Done"
