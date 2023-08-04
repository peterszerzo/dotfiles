# Mac OS Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap homebrew/cask
brew install brew-cask
brew tap caskroom/versions

# Brew install basics
brew install z tmux zsh zsh-completions lua-language-server
brew install reattach-to-user-namespace --with-wrap-pbcopy-and-pbpaste
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Desktop apps
brew cask install dash vlc 1password

npm i -g elm spaceship serve
