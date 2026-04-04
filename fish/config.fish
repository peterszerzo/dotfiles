fish_default_key_bindings

set -Ux EDITOR nvim
set -x MANPAGER "nvim +Man!"

set PATH /usr/local/bin /usr/bin /bin /usr/sbin /sbin /opt/homebrew/bin /opt/homebrew/sbin ~/.cargo/bin ~/.local/bin $PATH

set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin $PATH /Users/peterszerzo/.ghcup/bin # ghcup-env

export PATH="$HOME/.local/bin:$PATH"

abbr --add lgtm 'gh pr review --approve && gh pr merge --squash --auto && git checkout main && git branch -d @{-1}'
abbr --add keych 'ssh-add --apple-use-keychain ~/.ssh/id_ed25519'

function cwt --description "Create a worktree for Claude"
    if test (count $argv) -eq 0
        echo "Usage: cwt <branch-name>"
        return 1
    end
 
    set branch $argv[1]
    set worktree_path .claude/worktrees/$branch
 
    git worktree add $worktree_path -b $branch && cd $worktree_path
end
