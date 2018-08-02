# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH=LOCAL_PATH:$PATH

source $ZSH/oh-my-zsh.sh
source "/Users/peterszerzo/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

alias tmux="tmux -2"

# If on branch 'br', `git push` -> `git push origin br` 
git config --global push.default current

# Enable https://github.com/rupa/z
. ~/dotfiles/z.sh

ZSH_THEME="spaceship"

# Work out number lines of code in a given extension in the current directory
function loc {
  find . -name "*.$1" | xargs wc -l
}

# Start a fresh branch off of master
function freshbranch {
  git fetch
  git checkout origin/master
  git checkout -b $1
}
