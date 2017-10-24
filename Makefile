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
configure_linux: install_deps install_fish configure_multi_platform configure_xorg configure_dunst configure_dwm configure_git configure_fonts configure_services configure_slack install_kerl install_kiex

install_deps:
	xbps-install void-repo-multilib void-repo-multilib-nonfree void-repo-nonfree &&\
	xbps-install -S &&\
	xbps-install Thunar acpi alsa-tools alsa-utils bc cargo chromium cmake curl dmenu docker docker-compose dunst dwm emacs-gtk3 firefox font-fira-otf font-fira-ttf font-inconsolata-otf font-sourcecodepro fzf git glances gnome-ssh-askpass gnupg2 go htop libX11-devel libXft-devel libXinerama-devel libgit2-devel libressl-devel luakit mosh mtr ncurses-devel neomutt neovim ngrep nitrogen nmap notmuch numlockx offlineimap pass pfff pm-utils powertop ranger redshift ripgrep rust scrot slim slim-void-theme slock spotify st sysdig tig tmux ufw unzip vim vlc weechat wget wicd wicd-gtk wireshark xautolock xf86-video-nouveau xorg xorg-minimal xorg-server zip patch feh imapfilter pinentry-gtk paper-gtk-theme paper-icon-theme lxappearance wxWidgets wxWidgets-devel&&

install_fish:
	wget https://fishshell.com/files/2.6.0/fish-2.6.0.tar.gz &&\
	tar xvf fish-2.6.0.tar.gz &&\
        cd fish-2.6.0 &&\
        ./configure &&\
	make &&\
	sudo make install &&\
	cd .. &&\
	rm -rf fish-2.6.0

configure_xorg:
	-ln -si ${SOURCE}/xorg/xinitrc ~/.xinitrc

configure_dunst:
	-ln -sin ${SOURCE}/dunst ~/.config/dunst

configure_i3:
	-ln -sin ${SOURCE}/i3/config ~/.config/i3/config

configure_fonts:
	ln -s ${SOURCE}/xorg/Xresources ~/.Xresources
	ln -s ${SOURCE}/fonts.conf ~/.fonts.conf

configure_dwm:
	git clone https://git.suckless.org/dwm tmp-dwm
	cd tmp-dwm &&\
	git checkout 6.1 &&\
	patch < ../dwm-patches/dwm-6.1-unbalanced.diff &&\
	patch < ../dwm-patches/dwm-6.1-systray.diff    &&\
	sudo make clean install &&\
	cd .. &&\
	rm -rf tmp-dwm

configure_services:
	sudo ln -s /etc/sv/wicd/ /var/service/
	sudo ln -s /etc/sv/ufw/ /var/service/
	sudo ln -s /etc/sv/openntpd/ /var/service/
	sudo ln -s /etc/sv/slim /var/service/
	sudo ln -s /etc/sv/docker/ /var/service/

configure_slack:
	mkdir -p /tmp/slack &&\
	cd /tmp/slack &&\
	wget https://downloads.slack-edge.com/linux_releases/slack-desktop-2.8.2-amd64.deb &&\
	ar x slack-desktop-2.8.2-amd64.deb &&\
	tar xvf data.tar.xz &&\
	cp -r usr/ /

configure_wallpapers:
	-ln -sin ${SOURCE}/wallpapers ~/wallpapers
	feh --bg-max --randomize ~/wallpapers/

# multiplatform
configure_multi_platform: configure_tmux configure_weechat configure_fish configure_mail

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

install_kerl:
	curl -O https://raw.githubusercontent.com/kerl/kerl/master/kerl &&\
	chmod a+x kerl &&\
	sudo mv kerl /usr/local/bin/ &&\
	kerl build 20.1 20.1 &&\
	mkdir -p ~/erlang/20.1 &&\
	kerl install 20.1 ~/erlang/20.1/

install_kiex:
	curl -sSL https://raw.githubusercontent.com/taylor/kiex/master/install | bash -s &&\
	kiex install 1.4.5
