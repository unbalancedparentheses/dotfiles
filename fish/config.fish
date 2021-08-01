set fish_greeting ""

if [ (uname) = "OpenBSD" ]
   set -x PKG_PATH http://openbsd.cs.toronto.edu/pub/OpenBSD/snapshots/packages/amd64
end

set -x PATH $PATH ~/.cargo/bin/ ~/bin/discord/
set -x LC_ALL en_US.utf8
set -x LANG en_US.utf8

set -x PYENV_ROOT $HOME/.pyenv
set -x PATH $PYENV_ROOT/bin $PATH

status --is-interactive; and source

alias p python
alias e erl
alias ls exa
alias cat bat

zoxide init fish | source
