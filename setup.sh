
# Cleanup
cd ~
rm -rf dotfiles .config/nvim/init.lua .config/fish/config.fish .config/tmux/tmux.conf
git clone git@github.com:peterszerzo/dotfiles.git

# Set up symlinks
rm -rf ~/.config/nvim ~/.config/fish/config.fish ~/.config/fish/fish_plugins ~/.config/tmux/tmux.conf
ln -s ~/dotfiles/nvim ~/.config
ln -sv ~/dotfiles/fish/config.fish ~/.config/fish
ln -sv ~/dotfiles/fish/fish_plugins ~/.config/fish
ln -sv ~/dotfiles/fish/functions/fish_greeting.fish ~/.config/fish/functions
ln -sv ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
