SOURCE=${CURDIR}
UNAME := $(shell uname -s)

ifeq ($(UNAME), Darwin)
default: configure_osx
endif

ifeq ($(UNAME), Linux)
default: configure_linux
endif

# osx
configure_osx: configure_multi_platform
#	xcode-select --install
# 	while xcode-select -p 2>/dev/null
# 		do
# 			sleep 0.1
#       done
#
# 	if ! which -s brew
# 	then
# 		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# 	fi
# 	if ! brew cask >/dev/null 2>&1
# 	then
# 		brew tap caskroom/cask
# 		brew tap caskroom/versions
# 	fi
# 	brew cask install java
# 	brew install fish mosh fzf weechat wget curl tree git tmux vim mc tig

# 	brew cask install iterm2 emacs firefox google-chrome caffeine flux qbittorrent the-unarchiver skype vlc spotify appcleaner disk-inventory-x dash atom slack torbrowser
# 	brew install erlang elixir haskell-stack ghc the_silver_searcher jq icdiff cloc hub rebar python python3 ack tree mysql postgresql redis elasticsearch ruby-build leiningen

# brew install global --with-ctags --with-pygments

# 	if [ ! -d "~/.vim/" ]
# 	then
# 		curl -L https://raw.githubusercontent.com/unbalancedparentheses/vim-lunfardo/master/bootstrap.sh | bash
# 	fi

# 	if [ ! -d "~/.emacs.d/" ]
# 	then
# 		git clone --depth=1 https://github.com/unbalancedparentheses/emacs-lunfardo.git ~/.emacs.d/
# 		open /Applications/Emacs.app/
# 	fi

# 	defaults write com.apple.dock mru-spaces -bool false
# 	defaults write com.apple.dock autohide -boolean YES
# 	defaults write com.apple.dock magnification -boolean YES
# 	killall Dock

# linux
configure_linux: configure_multi_platform configure_xorg configure_dunst configure_i3

configure_xorg:
	-ln -si ${SOURCE}/xorg/xinitrc ~/.xinitrc

configure_dunst:
	-ln -sin ${SOURCE}/dunst ~/.config/dunst

configure_i3:
	mkdir -p ~/.config/i3/
	-ln -si ${SOURCE}/i3/config ~/.config/i3/config

configure_bspwm:
	-ln -si ${SOURCE}/bspwm ~/.config/bspwm
	-ln -si ${SOURCE}/sxhkd ~/.config/sxhkd

# multiplatform
configure_multi_platform: configure_tmux configure_weechat configure_fish configure_mail configure_bin

configure_tmux:
	-ln -si ${SOURCE}/tmux/tmux.conf ~/.tmux.conf

configure_weechat:
	-ln -si ${SOURCE}/weechat ~/.weechat

configure_fish:
	-ln -sni ${SOURCE}/fish ~/.config/fish

configure_git:
	-ln -si ${SOURCE}/git/gitconfig ~/.gitconfig

configure_mail:
	mkdir -p ~/.offlineimap/
	-ln -si ${SOURCE}/offlineimap/cert.pem ~/.offlineimap-cert.pem
	-ln -si ${SOURCE}/offlineimap/offlineimap.py ~/.offlineimap.py
	-ln -si ${SOURCE}/offlineimap/offlineimaprc ~/.offlineimaprc
	mkdir -p ~/.mutt/
	-ln -si ${SOURCE}/mutt/muttrc ~/.mutt/muttrc
	mkdir -p ~/.imapfilter/
	-ln -si ${SOURCE}/imapfilter/config.lua ~/.imapfilter/config.lua

configure_bin:
	-ln -sni ${SOURCE}/bin ~/bin
	echo  'export PATH=$PATH:~/bin/' > ~/.bash_profile
