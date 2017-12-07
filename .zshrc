# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH=LOCAL_PATH:$PATH

source $ZSH/oh-my-zsh.sh
source "/Users/peterszerzo/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

alias tmux="tmux -2"

ZSH_THEME="spaceship"

# Work out number lines of code in a given extension
function loc {
  find . -name "*.$1" | xargs wc -l
}
