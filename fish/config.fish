set fish_greeting ""

if [ (uname) = "OpenBSD" ]
   set -x PKG_PATH http://openbsd.cs.toronto.edu/pub/OpenBSD/snapshots/packages/amd64
end

set -x PATH $PATH ~/.mix ~/bin 
set -x LC_ALL en_US.utf8
set -x LANG en_US.utf8

source $HOME/.kiex/elixirs/.elixir-1.3.4.env.fish
source $HOME/erlang/19.3/activate.fish

