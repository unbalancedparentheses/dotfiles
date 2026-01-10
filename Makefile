.PHONY: help install switch update upgrade clean linux-dotfiles \
        openbsd-install openbsd-run openbsd-ssh openbsd-clean \
        void-install void-run void-gui void-headless void-ssh void-clean

.DEFAULT_GOAL := help

UNAME := $(shell uname -s)
USER  := $(shell whoami)

ifeq ($(UNAME),Darwin)
    OS  := macos
    NIX := /nix/var/nix/profiles/default/bin/nix
else
    OS  := linux
    NIX := nix
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
	@echo "VMs (macOS):"
	@echo "  openbsd-{install,run,ssh,clean}"
	@echo "  void-{install,run,gui,headless,ssh,clean}"

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
	ln -sfn $(CURDIR)/xorg/Xresources ~/.Xresources
	ln -sfn $(CURDIR)/xorg/fonts.conf ~/.fonts.conf
	ln -sfn $(CURDIR)/xorg/xinitrc ~/.xinitrc
	ln -sfn $(CURDIR)/dunst ~/.config/dunst
	ln -sfn $(CURDIR)/parcellite ~/.config/parcellite
	@echo "Linux dotfiles installed"

openbsd-%:
	@[ "$(OS)" = "macos" ] || { echo "macOS only"; exit 1; }
	./openbsd-vm/setup.sh $*

void-%:
	@[ "$(OS)" = "macos" ] || { echo "macOS only"; exit 1; }
	./void-vm/setup.sh $*
