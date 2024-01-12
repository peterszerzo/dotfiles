cd ~

# Cleanup
rm -rf dotfiles .config/nvim/init.lua .config/fish/config.fish .config/tmux/tmux.conf

git clone git@github.com:peterszerzo/dotfiles.git
cd dotfiles

# Set up symlinks
cd ~
ln -sv ~/dotfiles/init.lua ~/.config/nvim
ln -sv ~/dotfiles/config.fish ~/.config/fish
ln -sv ~/dotfiles/tmux/tmux.conf ~/.config/tmux
