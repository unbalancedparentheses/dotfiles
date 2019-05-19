SOURCE=${CURDIR}
UNAME := $(shell uname -s)

ifeq ($(UNAME), Darwin)
default: configure_osx
endif

ifeq ($(UNAME), Linux)
default: configure_linux
endif

configure_linux: configure_dunst configure_xorg configure_dwm configure_parcellite configure_tmux configure_fish configure_git configure_services

configure_dunst:
	-ln -sin ${SOURCE}/dunst ~/.config/dunst

configure_xorg:
	-ln -s ${SOURCE}/xorg/Xresources ~/.Xresources
	-ln -s ${SOURCE}/fonts.conf ~/.fonts.conf

configure_dwm:
	git clone https://git.suckless.org/dwm tmp-dwm
	cd tmp-dwm &&\
	git checkout 6.1 &&\
	patch < ../dwm-patches/dwm-6.1-unbalanced.diff &&\
	patch < ../dwm-patches/dwm-6.1-systray.diff &&\
	sudo make clean install &&\
	cd .. &&\
	rm -rf tmp-dwm

configure_parcellite:
	-ln -sin ${SOURCE}/parcellite ~/.config/parcellite

configure_tmux:
	-ln -si ${SOURCE}/tmux/tmux.conf ~/.tmux.conf

configure_fish:
	-ln -sni ${SOURCE}/fish ~/.config/fish

configure_git:
	-ln -si ${SOURCE}/git/gitconfig ~/.gitconfig

configure_services:
	sudo ln -s /etc/sv/wicd/ /var/service/
	sudo ln -s /etc/sv/ufw/ /var/service/
	sudo ln -s /etc/sv/openntpd/ /var/service/
	sudo ln -s /etc/sv/slim /var/service/
	sudo ln -s /etc/sv/docker/ /var/service/
