#!/bin/sh
set -eu

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

# Install fish plugins from fish_plugins (needs fisher, installed by new-machine.sh)
fish -c 'fisher update'
