.PHONY: dunst fish git tmux xorg nix
SOURCE=${CURDIR}
UNAME := $(shell uname -s)

ifeq ($(UNAME), Darwin)
default: osx
endif

ifeq ($(UNAME), Linux)
default: linux
endif

linux: void nix fish tmux git docker services xorg dwm emacs dunst slstatus fonts

backup_void_packages:
	xbps-query -m | sed 's|\(.*\)-.*|\1|' > void_packages

void:
	cat void_packages | xargs echo "xbps-install -Sy" | sudo bash

nix:
	nix-channel --add https://nixos.org/channels/nixpkgs-unstable
	nix-channel --update
	nix-env -u
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update
	ln -sin ${SOURCE}/nix/home.nix ~/.config/nixpkgs/home.nix
	nix-shell '<home-manager>' -A install
	home-manager switch

fish:
	-ln -sin ${SOURCE}/fish/* ~/.config/fish/

tmux:
	-ln -sin ${SOURCE}/tmux/tmux.conf ~/.tmux.conf

git:
	-ln -sin ${SOURCE}/git/gitconfig ~/.gitconfig

docker:
	sudo usermod -aG docker ${USER}

services:
	-sudo ln -sin /etc/sv/ufw/ /var/service/
	-sudo ln -sin /etc/sv/nix-daemon/ /var/service/
	-sudo ln -sin /etc/sv/ntpd/ /var/service/
	-sudo ln -sin /etc/sv/slim /var/service/
	-sudo ln -sin /etc/sv/docker/ /var/service/
	-sudo ln -sin /etc/sv/NetworkManager /var/service/
	-sudo ln -sin /etc/sv/dbus /var/service
	-sudo rm -f /var/service/dhcpcd

xorg:
	ln -sin ${SOURCE}/xorg/Xresources ~/.Xresources
	ln -sin ${SOURCE}/xorg/fonts.conf ~/.fonts.conf
	ln -sin ${SOURCE}/xorg/xinitrc ~/.xinitrc

dwm:
	git clone https://git.suckless.org/dwm tmp-dwm
	cd tmp-dwm &&\
	git checkout 6.1 &&\
	patch < ../dwm-patches/dwm-6.1-unbalanced.diff &&\
	patch < ../dwm-patches/dwm-6.1-systray.diff &&\
	sudo make clean install

emacs:
	rm -rf ~/.emacs.d/
	git clone https://github.com/unbalancedparentheses/emacs-lunfardo.git ~/.emacs.d/

dunst:
	ln -sin ${SOURCE}/dunst ~/.config/dunst

slstatus:
	git clone https://git.suckless.org/slstatus
	cd slstatus &&\
	sudo make clean install

fonts:
	-sudo ln -sin /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
	-sudo ln -sin /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
	-sudo ln -sin /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
	-sudo ln -sin /usr/share/fontconfig/conf.avail/50-user.conf /etc/fonts/conf.d/
	-sudo ln -sin /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/

restricted:
	sudo xbps-install -Sy xtools
	git clone git://github.com/void-linux/void-packages.git
	cd void-packages/
	echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf
	./xbps-src binary-bootstrap
	./xbps-src pkg slack-desktop
	xi slack-desktop

