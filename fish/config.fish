set -g fish_key_bindings fish_default_key_bindings

set -Ux EDITOR nvim
set -x MANPAGER "nvim +Man!"

set PATH /usr/local/bin /usr/bin /bin /usr/sbin /sbin /opt/homebrew/bin /opt/homebrew/sbin ~/.local/bin $PATH

abbr --add keych 'ssh-add --apple-use-keychain ~/.ssh/id_ed25519'
abbr --add ghprco 'gh pr checkout'
abbr --add ghprl 'gh pr list'
abbr --add ffs --set-cursor 'firefox --search "%"'

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

# eza as the ls replacement - skipped if it isn't installed yet, so a fresh
# machine still has a working `ls` before new-machine.sh runs
if command -q eza
  # eza 0.23.5 prints nothing at all when called without an explicit path, so
  # add `.` when the caller passed only flags. Use the --flag=value form for
  # flags that take a value, or the value looks like a path to this check.
  function __eza
    for arg in $argv
      if string match --quiet --invert -- '-*' $arg
        eza $argv
        return
      end
    end

    eza $argv .
  end

  # Plain listing, closest to `ls`; use `command ls` for the real thing
  function ls
    __eza --group-directories-first --icons=auto $argv
  end

  # Long listing with git status per file
  function ll
    __eza --long --header --git --group-directories-first --icons=auto --time-style=long-iso $argv
  end

  # Long listing including dotfiles
  function la
    ll --all $argv
  end

  # Tree, two levels deep by default; pass --level=N to override
  function lt
    __eza --tree --level=2 --group-directories-first --icons=auto $argv
  end
end

#
# Begin `ql`
#


# Quick links - run `ql --help` for the full API. The link list lives outside
# this repo so it can hold personal URLs; override the path with $QL_FILE.
set -q QL_FILE; or set -gx QL_FILE ~/.local/share/ql/links.tsv

# Every stored link as a `name<TAB>url` line, skipping comments and blanks
function __ql_entries
  test -f $QL_FILE; or return 0

  # With --delimiter, $url gets everything after the first tab, untrimmed
  while read --delimiter=\t --local name url
    string match --quiet --regex '^\s*(#|$)' -- $name; and continue
    test -n "$url"; or continue
    printf '%s\t%s\n' $name $url
  end < $QL_FILE
end

# The URL stored under a link name, or a non-zero status if there is no such link
function __ql_url
  for entry in (__ql_entries)
    set -l parts (string split --max 1 \t -- $entry)
    if test "$parts[1]" = "$argv[1]"
      echo $parts[2]
      return 0
    end
  end

  return 1
end

# Fill the {placeholder} and {placeholder=default} tokens of the URL in $argv[1],
# taking values from the remaining `key=value` and positional args and prompting
# for whatever is left. The result lands in $__ql_filled rather than on stdout,
# since the prompts would end up captured along with it.
function __ql_fill
  set -g __ql_filled $argv[1]
  set -l keys
  set -l values
  set -l positional

  for arg in $argv[2..]
    set -l parts (string split --max 1 = -- $arg)
    if test (count $parts) -eq 2; and string match --quiet --regex '^[A-Za-z_][A-Za-z0-9_-]*$' -- $parts[1]
      set -a keys $parts[1]
      set -a values $parts[2]
    else
      set -a positional $arg
    end
  end

  for token in (string match --all --regex '\{[^{}]*\}' -- $argv[1])
    set -l parts (string split --max 1 = -- (string replace --regex '^\{(.*)\}$' '$1' -- $token))
    set -l key $parts[1]
    set -l default ''
    test (count $parts) -eq 2; and set default $parts[2]

    set -l value
    set -l idx (contains --index -- $key $keys)
    if test -n "$idx"
      set value $values[$idx]
    else if set -q positional[1]
      set value $positional[1]
      set -e positional[1]
    else
      set -l prompt "$key: "
      test -n "$default"; and set prompt "$key [$default]: "
      read --prompt-str=$prompt --local reply
      set value $reply
    end

    test -n "$value"; or set value $default
    if test -z "$value"
      echo "ql: no value given for {$key}" >&2
      set -e __ql_filled
      return 1
    end

    set __ql_filled (string replace --all -- $token (string replace --all ' ' %20 -- $value) $__ql_filled)
  end

  # A URL without placeholders leaves the failing `string match` as the last status
  return 0
end

function __ql_open
  if command -q open
    open $argv
  else if command -q xdg-open
    xdg-open $argv
  else
    echo 'ql: found neither open nor xdg-open' >&2
    return 1
  end
end

# Resolve a link name - falling back to an fzf pick, using the name as the
# initial query - then open it ($argv[1] = open) or print it ($argv[1] = print)
function __ql_run
  set -l mode $argv[1]
  set -l name $argv[2]
  set -l fill $argv[3..]

  if test -z "$name"; or not __ql_url "$name" >/dev/null
    if not command -q fzf
      test -n "$name"; and echo "ql: no link named '$name'" >&2
      test -n "$name"; or echo 'ql: pass a link name (fzf is not installed)' >&2
      return 1
    end

    set -l picked (__ql_entries | fzf --delimiter=\t --with-nth=1,2 --prompt='ql> ' --query="$name")
    test -n "$picked"; or return 1
    set name (string split --max 1 \t -- $picked)[1]
  end

  __ql_fill (__ql_url $name) $fill; or return 1
  set -l url $__ql_filled
  set -e __ql_filled

  if test "$mode" = print
    echo $url
  else
    __ql_open $url
  end
end

function __ql_usage
  printf '%s\n' \
    'ql - quick links' \
    '' \
    'Usage:' \
    '  ql                            pick a link with fzf and open it' \
    '  ql <name> [values...]         open a link, filling its placeholders' \
    '  ql <query> [values...]        no such name? fall back to an fzf pick' \
    '  ql get <name> [values...]     print the resolved URL instead of opening it' \
    '  ql add <name> <url>           store a link' \
    '  ql rm <name>                  remove a link' \
    '  ql ls                         list links' \
    '  ql edit                       open the link file in $EDITOR' \
    '  ql path                       print the path to the link file' \
    '' \
    'Placeholders:' \
    '  {profile}                     prompts for a value' \
    '  {profile=peterszerzo}         prompts, and empty input takes the default' \
    '' \
    '  Values are passed positionally in the order they appear, or by name:' \
    '    ql add gh "https://github.com/{profile}/{repo=dotfiles}"' \
    '    ql gh octocat hello-world   -> https://github.com/octocat/hello-world' \
    '    ql gh profile=octocat       -> prompts for repo, empty input = dotfiles' \
    '' \
    '  Quote URLs containing {braces} when adding them, otherwise fish' \
    '  expands the braces away. Spaces in values become %20, everything' \
    '  else is inserted as typed.' \
    '' \
    'Storage:' \
    "  $QL_FILE" \
    '  One name<TAB>url per line; # comments and blank lines are ignored.'
end

function ql --description 'Open a quick link'
  set -l cmd $argv[1]
  set -l rest $argv[2..]

  switch "$cmd"
    case -h --help help
      __ql_usage

    case add
      if test (count $rest) -ne 2
        echo 'ql: usage: ql add <name> <url>' >&2
        return 1
      end

      set -l name $rest[1]
      if string match --quiet --regex '\s' -- $name
        echo 'ql: link names cannot contain whitespace' >&2
        return 1
      end
      if contains -- $name add rm remove ls list edit path get help
        echo "ql: '$name' is a reserved subcommand name" >&2
        return 1
      end
      if __ql_url $name >/dev/null
        echo "ql: '$name' already exists - remove it first with: ql rm $name" >&2
        return 1
      end

      mkdir -p (dirname $QL_FILE)
      printf '%s\t%s\n' $name $rest[2] >> $QL_FILE
      echo "ql: added $name -> $rest[2]"

    case rm remove
      if test (count $rest) -ne 1
        echo 'ql: usage: ql rm <name>' >&2
        return 1
      end
      if not __ql_url $rest[1] >/dev/null
        echo "ql: no link named '$rest[1]'" >&2
        return 1
      end

      set -l tmp (mktemp)
      while read --delimiter=\t --local name url
        if test "$name" = "$rest[1]"; and test -n "$url"
          continue
        end
        if test -n "$url"
          printf '%s\t%s\n' $name $url
        else
          printf '%s\n' $name
        end
      end < $QL_FILE > $tmp
      mv $tmp $QL_FILE
      echo "ql: removed $rest[1]"

    case ls list
      set -l entries (__ql_entries)
      test -n "$entries"; or return 0

      set -l width 0
      for entry in $entries
        set -l name (string split --max 1 \t -- $entry)[1]
        test (string length -- $name) -gt $width; and set width (string length -- $name)
      end
      for entry in $entries
        set -l parts (string split --max 1 \t -- $entry)
        printf '%s  %s\n' (string pad --right --width $width -- $parts[1]) $parts[2]
      end

    case edit
      mkdir -p (dirname $QL_FILE)
      $EDITOR $QL_FILE

    case path
      echo $QL_FILE

    case get
      __ql_run print $rest

    case '*'
      __ql_run open $argv
  end
end

# Placeholder keys of the link named in the command line, as `key=` completions
function __ql_placeholders
  set -l tokens (commandline --cut-at-cursor --tokenize)
  set -q tokens[2]; or return 0
  set -l url (__ql_url $tokens[2]); or return 0

  for token in (string match --all --regex '\{[^{}]*\}' -- $url)
    set -l spec (string replace --regex '^\{(.*)\}$' '$1' -- $token)
    printf '%s=\n' (string split --max 1 = -- $spec)[1]
  end
end

complete -c ql -f
complete -c ql -s h -l help -d 'Show usage'
complete -c ql -n __fish_is_first_arg -a '(__ql_entries)'
complete -c ql -n __fish_is_first_arg -a add -d 'Store a link'
complete -c ql -n __fish_is_first_arg -a rm -d 'Remove a link'
complete -c ql -n __fish_is_first_arg -a ls -d 'List links'
complete -c ql -n __fish_is_first_arg -a edit -d 'Edit the link file'
complete -c ql -n __fish_is_first_arg -a path -d 'Print the link file path'
complete -c ql -n __fish_is_first_arg -a get -d 'Print a resolved URL'
complete -c ql -n '__fish_seen_subcommand_from rm remove get' -a '(__ql_entries)'
complete -c ql -n 'not __fish_is_first_arg' -a '(__ql_placeholders)'

#
# End `ql`
#

if test -f ~/.config/fish/local.fish
  source ~/.config/fish/local.fish
end

zoxide init fish | source
fzf --fish | source
