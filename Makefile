.PHONY: help install switch update upgrade clean linux-dotfiles

.DEFAULT_GOAL := help

UNAME := $(shell uname -s)
USER  := $(shell whoami)

ifeq ($(UNAME),Darwin)
    OS  := macos
    NIX := /nix/var/nix/profiles/default/bin/nix --extra-experimental-features 'nix-command flakes'
else
    OS  := linux
    NIX := nix --extra-experimental-features 'nix-command flakes'
endif

help:
	@echo "Dotfiles ($(OS))"
	@echo ""
	@echo "  install   First-time installation"
	@echo "  switch    Rebuild and switch configuration"
	@echo "  update    Update flake inputs"
	@echo "  upgrade   Update and switch"
	@echo "  clean     Garbage collect"
	@echo ""
	@echo "Linux:"
	@echo "  linux-dotfiles  Symlink xorg, dunst, parcellite configs"
	@echo ""
	@echo "VMs (macOS only):"
	@echo "  nixos-{install,run,gui,ssh,clean}   port 2224"
	@echo "  openbsd-{install,run,ssh,clean}     port 2222"
	@echo "  void-{install,run,gui,ssh,clean}    port 2223"

switch:
	@if [ "$(UNAME)" = "Darwin" ]; then \
		sed -i '' 's/username = "[^"]*";/username = "$(USER)";/' flake.nix; \
	else \
		sed -i 's/username = "[^"]*";/username = "$(USER)";/' flake.nix; \
	fi
	@if [ "$(OS)" = "macos" ]; then \
		sudo -H $(NIX) run nix-darwin -- switch --flake ".#default"; \
	else \
		home-manager switch --flake .#linux -b backup; \
	fi

install:
	@if [ "$(UNAME)" = "Darwin" ]; then \
		sed -i '' 's/username = "[^"]*";/username = "$(USER)";/' flake.nix; \
	else \
		sed -i 's/username = "[^"]*";/username = "$(USER)";/' flake.nix; \
	fi
	@if [ "$(OS)" = "macos" ]; then \
		sudo -H $(NIX) run nix-darwin -- switch --flake ".#default"; \
	else \
		nix run home-manager -- switch --flake .#linux -b backup; \
	fi

update:
	$(NIX) flake update

upgrade: update switch

clean:
	@if [ "$(OS)" = "macos" ]; then \
		sudo $(NIX) store gc; \
	else \
		$(NIX) store gc; \
	fi

linux-dotfiles:
	mkdir -p ~/.config
	ln -sfn $(CURDIR)/linux/xorg/Xresources ~/.Xresources
	ln -sfn $(CURDIR)/linux/xorg/fonts.conf ~/.fonts.conf
	ln -sfn $(CURDIR)/linux/xorg/xinitrc ~/.xinitrc
	ln -sfn $(CURDIR)/linux/dunst ~/.config/dunst
	ln -sfn $(CURDIR)/linux/parcellite ~/.config/parcellite
	@echo "Linux dotfiles installed"

nixos-%:
	@[ "$(OS)" = "macos" ] || { echo "macOS only"; exit 1; }
	./vms/nixos/setup.sh $*

openbsd-%:
	@[ "$(OS)" = "macos" ] || { echo "macOS only"; exit 1; }
	./vms/openbsd/setup.sh $*

void-%:
	@[ "$(OS)" = "macos" ] || { echo "macOS only"; exit 1; }
	./vms/void/setup.sh $*
