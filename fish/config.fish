fish_default_key_bindings

set -Ux EDITOR nvim
set -x MANPAGER "nvim +Man!"

set PATH /usr/local/bin /usr/bin /bin /usr/sbin /sbin /opt/homebrew/bin /opt/homebrew/sbin ~/.cargo/bin $PATH

set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin $PATH /Users/peterszerzo/.ghcup/bin # ghcup-env

# ssh-add --apple-use-keychain ~/.ssh/id_ed25519
