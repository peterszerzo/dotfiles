# Mac OS Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Brew install basics
brew install gh yazi fzf ripgrep lazygit fish neovim tmux lua-language-server zoxide

gh extension install dlvhdr/gh-dash

# Desktop apps
brew install --cask raycast vlc arc firefox kitty 1password

npm i -g elm serve @elm-tooling/elm-language-server
