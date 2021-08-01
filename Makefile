.PHONY: dunst fish git tmux xorg 
SOURCE=${CURDIR}
UNAME := $(shell uname -s)

ifeq ($(UNAME), Darwin)
default: _osx
endif

ifeq ($(UNAME), Linux)
default: linux
endif

linux: dunst xorg fonts dwm tmux fish git services

dunst:
	ln -sin ${SOURCE}/dunst ~/.config/dunst

xorg:
	ln -sin ${SOURCE}/xorg/Xresources ~/.Xresources
	ln -sin ${SOURCE}/xorg/fonts.conf ~/.fonts.conf
	ln -sin ${SOURCE}/xorg/xinitrc ~/.xinitrc
	
fonts:
	sudo ln -s /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
	sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
	sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
	sudo ln -s /usr/share/fontconfig/conf.avail/50-user.conf /etc/fonts/conf.d/
	sudo ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/

dwm:
	git clone https://git.suckless.org/dwm tmp-dwm
	cd tmp-dwm &&\
	git checkout 6.1 &&\
	patch < ../dwm-patches/dwm-6.1-unbalanced.diff &&\
	patch < ../dwm-patches/dwm-6.1-systray.diff &&\
	sudo make clean install

tmux:
	ln -sin ${SOURCE}/tmux/tmux.conf ~/.tmux.conf

fish:
	ln -sin ${SOURCE}/fish/* ~/.config/fish/

git:
	ln -sin ${SOURCE}/git/gitconfig ~/.gitconfig

services:
	ln -s /etc/sv/ufw/ /var/service/
	ln -s /etc/sv/nix-daemon/ /var/service/
	ln -s /etc/sv/ntpd/ /var/service/
	ln -s /etc/sv/slim /var/service/
	ln -s /etc/sv/docker/ /var/service/
	ln -s /etc/sv/NetworkManager /var/service/
	ln -s /etc/sv/dbus /var/service
