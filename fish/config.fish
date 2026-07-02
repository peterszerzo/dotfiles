set -g fish_key_bindings fish_default_key_bindings

set -Ux EDITOR nvim
set -x MANPAGER "nvim +Man!"

set PATH /usr/local/bin /usr/bin /bin /usr/sbin /sbin /opt/homebrew/bin /opt/homebrew/sbin ~/.local/bin $PATH

abbr --add keych 'ssh-add --apple-use-keychain ~/.ssh/id_ed25519'
abbr --add ghprco 'gh pr checkout'
abbr --add ghprl 'gh pr list'

# Get the origin of a GitHub PR - either by PR number or without an argument for the current PR
function ghprog 
    # If a PR number is given, check it out first
    if set -q argv[1]
        gh pr view $argv[1] --json headRefName,baseRefName
    end

    gh pr view --json headRefName,baseRefName
end

# The GitHub PR looks good to me - approve, merge, delete and forget the PR based on the current branch, check out `main` in the end
function lgtm
    # If a PR number is given, check it out first
    if set -q argv[1]
        gh pr checkout $argv[1]; or return
    end

    gh pr review --approve
        and gh pr merge --squash --auto
        and git checkout main
        and git branch -d @{-1}
end

if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end

zoxide init fish | source
fzf --fish | source
