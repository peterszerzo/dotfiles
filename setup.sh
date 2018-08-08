cd ~

# Cleanup
rm -rf dotfiles .zshrc .vimrc .tmux.conf

git clone git@github.com:peterszerzo/dotfiles.git
cd dotfiles
git clone git@github.com:rupa/z.git
chmod +x z/z.sh

# Set up symlinks
cd ~
ln -sv ~/dotfiles/.zshrc ~
ln -sv ~/dotfiles/.vimrc ~
ln -sv ~/dotfiles/.tmux.conf ~
