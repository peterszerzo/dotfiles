#!/bin/sh
set -eu

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

# Cleanup
cd ~
rm -rf dotfiles .config/nvim .config/fish .tmux.conf .config/kitty/kitty.conf .config/lazygit/config.yml
git clone git@github.com:peterszerzo/dotfiles.git

mkdir -p .config .config/kitty .config/lazygit

# Set up symlinks
ln -sv ~/dotfiles/nvim ~/.config
ln -sv ~/dotfiles/fish ~/.config
ln -sv ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -sv ~/dotfiles/kitty.conf ~/.config/kitty/kitty.conf
ln -sv ~/dotfiles/lazygit/config.yml ~/.config/lazygit/config.yml
ln -sv ~/dotfiles/lazygit/config.yml ~/Library/Application\ Support/lazygit/config.yml

# Install fish plugins from fish_plugins (needs fisher, installed by new-machine.sh)
fish -c 'fisher update'
