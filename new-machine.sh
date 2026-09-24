# Mac OS Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Brew install basics
brew install gh yazi fzf ripgrep lazygit fish neovim tmux lua-language-server zoxide delta ffmpeg tree-sitter-cli node eza

gh extension install dlvhdr/gh-dash

# Desktop apps
brew install --cask raycast vlc firefox kitty

npm i -g elm serve @elm-tooling/elm-language-server

# Fisher, the fish plugin manager; setup.sh installs the plugins themselves
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
