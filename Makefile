.PHONY: help install switch update upgrade clean check linux-dotfiles

.DEFAULT_GOAL := help

UNAME := $(shell uname -s)
USER  := $(shell whoami)

ifeq ($(UNAME),Darwin)
    OS  := macos
    NIX := /nix/var/nix/profiles/default/bin/nix --extra-experimental-features 'nix-command flakes'
    IS_NIXOS := 0
    IS_VOID  := 0
else
    OS  := linux
    NIX := nix --extra-experimental-features 'nix-command flakes'
    # Detect Linux distro
    IS_NIXOS := $(shell [ -f /etc/NIXOS ] && echo 1 || echo 0)
    IS_VOID  := $(shell [ -f /etc/void-release ] && echo 1 || echo 0)
endif

define update_username
	@sed -i.bak 's/username = "[^"]*";/username = "$(USER)";/' flake.nix && rm -f flake.nix.bak
endef

define backup_etc_files
	@for f in /etc/zshenv /etc/zshrc /etc/bashrc /etc/bash.bashrc; do \
		if [ -f "$$f" ] && [ ! -L "$$f" ]; then \
			echo "Moving $$f to $$f.before-nix-darwin"; \
			sudo mv "$$f" "$$f.before-nix-darwin"; \
		fi; \
	done
endef

help:
	@echo "Dotfiles ($(OS))"
	@echo ""
	@echo "  install   First-time installation"
	@echo "  switch    Rebuild and switch configuration"
	@echo "  update    Update flake inputs"
	@echo "  upgrade   Update and switch"
	@echo "  clean     Garbage collect"
	@echo "  check     Verify installation"
	@echo ""
	@echo "Linux extras (auto-run on Void, manual otherwise):"
	@echo "  linux-dotfiles  Symlink xorg, dunst, parcellite configs"
	@echo ""
	@echo "VMs (macOS only):"
	@echo "  nixos-{install,run,gui,ssh,clean}   port 2224"
	@echo "  openbsd-{install,run,ssh,clean}     port 2222"
	@echo "  void-{install,run,gui,ssh,clean}    port 2223"

switch:
	$(update_username)
ifeq ($(OS),macos)
	$(backup_etc_files)
	sudo -H $(NIX) run nix-darwin -- switch --flake ".#default"
	@pgrep -q AeroSpace && aerospace reload-config || echo "Note: Run 'open -a AeroSpace' to start the window manager"
	@pgrep -q sketchybar && sketchybar --reload || true
else
	home-manager switch --flake .#linux -b backup
ifeq ($(IS_VOID),1)
	@$(MAKE) linux-dotfiles
endif
endif

install:
	$(update_username)
ifeq ($(OS),macos)
	$(backup_etc_files)
	sudo -H $(NIX) run nix-darwin -- switch --flake ".#default"
	@pgrep -q AeroSpace && aerospace reload-config || true
	@pgrep -q sketchybar && sketchybar --reload || true
else
	nix run home-manager -- switch --flake .#linux -b backup
ifeq ($(IS_VOID),1)
	@$(MAKE) linux-dotfiles
endif
endif

update:
	$(NIX) flake update

upgrade: update switch

clean:
	@if [ "$(OS)" = "macos" ]; then \
		sudo $(NIX) store gc; \
	else \
		$(NIX) store gc; \
	fi

check:
	@echo "Checking installation..."
	@command -v nix >/dev/null && echo "✓ nix" || echo "✗ nix"
	@command -v fish >/dev/null && echo "✓ fish" || echo "✗ fish"
	@command -v nvim >/dev/null && echo "✓ nvim" || echo "✗ nvim"
	@command -v git >/dev/null && echo "✓ git" || echo "✗ git"
	@command -v tmux >/dev/null && echo "✓ tmux" || echo "✗ tmux"
	@command -v starship >/dev/null && echo "✓ starship" || echo "✗ starship"
	@command -v eza >/dev/null && echo "✓ eza" || echo "✗ eza"
	@command -v bat >/dev/null && echo "✓ bat" || echo "✗ bat"
	@command -v fzf >/dev/null && echo "✓ fzf" || echo "✗ fzf"
	@command -v rg >/dev/null && echo "✓ ripgrep" || echo "✗ ripgrep"
	@command -v fd >/dev/null && echo "✓ fd" || echo "✗ fd"
	@command -v lazygit >/dev/null && echo "✓ lazygit" || echo "✗ lazygit"
	@command -v zoxide >/dev/null && echo "✓ zoxide" || echo "✗ zoxide"
	@[ -f ~/.config/ghostty/config ] && echo "✓ ghostty config" || echo "✗ ghostty config"
	@[ -f ~/.config/zed/settings.json ] && echo "✓ zed config" || echo "✗ zed config"

define backup_dotfile
	@if [ -f "$(1)" ] && [ ! -L "$(1)" ]; then \
		echo "Backing up $(1) to $(1).backup"; \
		mv "$(1)" "$(1).backup"; \
	fi
endef

linux-dotfiles:
	mkdir -p ~/.config
	$(call backup_dotfile,~/.Xresources)
	$(call backup_dotfile,~/.fonts.conf)
	$(call backup_dotfile,~/.xinitrc)
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
