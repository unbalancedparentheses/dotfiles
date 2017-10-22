set fish_greeting ""

if [ (uname) = "OpenBSD" ]
   set -x PKG_PATH http://openbsd.cs.toronto.edu/pub/OpenBSD/snapshots/packages/amd64
end

set -x PATH /opt/firefox/ $PATH ~/.mix ~/bin ~/.cargo/bin/
set -x LC_ALL en_US.utf8
set -x LANG en_US.utf8

source $HOME/.kerl/installs/20.1/activate.fish
source $HOME/.kiex/scripts/kiex.fish
source $HOME/.kiex/elixirs/.elixir-1.4.5.env.fish