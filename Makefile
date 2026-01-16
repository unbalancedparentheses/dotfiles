.PHONY: help install update upgrade clean check suckless

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
	@echo "  update    Rebuild config and install tools"
	@echo "  upgrade   Update flake inputs + update"
	@echo "  clean     Garbage collect"
	@echo "  check     Verify installation"
	@echo ""
	@echo "Linux (suckless):"
	@echo "  suckless  Clone and setup dwm, st, slstatus"
	@echo ""
	@echo "VMs (macOS only):"
	@echo "  nixos-{install,run,gui,ssh,clean}   port 2224"
	@echo "  openbsd-{install,run,ssh,clean}     port 2222"
	@echo "  void-{install,run,gui,ssh,clean}    port 2223"

update:
	$(update_username)
ifeq ($(OS),macos)
	$(backup_etc_files)
	sudo -H $(NIX) run nix-darwin -- switch --flake ".#default"
	@pgrep -q AeroSpace && aerospace reload-config || echo "Note: Run 'open -a AeroSpace' to start the window manager"
	@pgrep -q sketchybar && sketchybar --reload || true
	@echo ""
	@echo "Installing development tools via mise..."
	@/run/current-system/sw/bin/mise install -y 2>/dev/null || mise install -y 2>/dev/null || echo "Run 'mise install' in a new terminal"
else
	home-manager switch --flake .#linux -b backup
	@echo ""
	@echo "Installing development tools via mise..."
	@~/.nix-profile/bin/mise install -y 2>/dev/null || mise install -y 2>/dev/null || echo "Run 'mise install' in a new terminal"
	@echo ""
	@echo "Run 'make suckless' to build dwm, st, slstatus"
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
	@echo ""
	@echo "Run 'make suckless' to build dwm, st, slstatus"
endif

upgrade:
	$(NIX) flake update
	$(MAKE) update

clean:
	@if [ "$(OS)" = "macos" ]; then \
		sudo $(NIX) store gc; \
	else \
		$(NIX) store gc; \
	fi

check:
	@echo "Checking installation ($(OS))..."
	@echo ""
	@echo "Core tools:"
	@command -v nix >/dev/null && echo "  ✓ nix" || echo "  ✗ nix"
	@command -v fish >/dev/null && echo "  ✓ fish" || echo "  ✗ fish"
	@command -v nvim >/dev/null && echo "  ✓ nvim" || echo "  ✗ nvim"
	@command -v emacs >/dev/null && echo "  ✓ emacs" || echo "  ✗ emacs"
	@command -v git >/dev/null && echo "  ✓ git" || echo "  ✗ git"
	@command -v tmux >/dev/null && echo "  ✓ tmux" || echo "  ✗ tmux"
	@command -v starship >/dev/null && echo "  ✓ starship" || echo "  ✗ starship"
	@echo ""
	@echo "CLI tools:"
	@command -v eza >/dev/null && echo "  ✓ eza" || echo "  ✗ eza"
	@command -v bat >/dev/null && echo "  ✓ bat" || echo "  ✗ bat"
	@command -v fzf >/dev/null && echo "  ✓ fzf" || echo "  ✗ fzf"
	@command -v rg >/dev/null && echo "  ✓ ripgrep" || echo "  ✗ ripgrep"
	@command -v fd >/dev/null && echo "  ✓ fd" || echo "  ✗ fd"
	@command -v lazygit >/dev/null && echo "  ✓ lazygit" || echo "  ✗ lazygit"
	@command -v zoxide >/dev/null && echo "  ✓ zoxide" || echo "  ✗ zoxide"
	@command -v atuin >/dev/null && echo "  ✓ atuin" || echo "  ✗ atuin"
	@command -v mise >/dev/null && echo "  ✓ mise" || echo "  ✗ mise"
	@command -v just >/dev/null && echo "  ✓ just" || echo "  ✗ just"
	@command -v difft >/dev/null && echo "  ✓ difftastic" || echo "  ✗ difftastic"
	@command -v sd >/dev/null && echo "  ✓ sd" || echo "  ✗ sd"
	@command -v hyperfine >/dev/null && echo "  ✓ hyperfine" || echo "  ✗ hyperfine"
	@command -v tokei >/dev/null && echo "  ✓ tokei" || echo "  ✗ tokei"
ifeq ($(OS),macos)
	@echo ""
	@echo "macOS configs:"
	@[ -f ~/.config/ghostty/config ] && echo "  ✓ ghostty" || echo "  ✗ ghostty"
	@[ -f ~/.config/zed/settings.json ] && echo "  ✓ zed" || echo "  ✗ zed"
	@[ -f ~/.config/aerospace/aerospace.toml ] && echo "  ✓ aerospace" || echo "  ✗ aerospace"
	@[ -f ~/.config/sketchybar/sketchybarrc ] && echo "  ✓ sketchybar" || echo "  ✗ sketchybar"
else
	@echo ""
	@echo "Linux (suckless):"
	@command -v dwm >/dev/null && echo "  ✓ dwm" || echo "  ✗ dwm (run: make suckless)"
	@command -v st >/dev/null && echo "  ✓ st" || echo "  ✗ st (run: make suckless)"
	@command -v slstatus >/dev/null && echo "  ✓ slstatus" || echo "  ✗ slstatus (run: make suckless)"
	@echo ""
	@echo "Linux (nix-managed):"
	@command -v rofi >/dev/null && echo "  ✓ rofi" || echo "  ✗ rofi"
	@command -v picom >/dev/null && echo "  ✓ picom" || echo "  ✗ picom"
	@command -v dunst >/dev/null && echo "  ✓ dunst" || echo "  ✗ dunst"
endif

suckless:
	@echo "Building suckless software (st, dwm, slstatus)..."
	@echo ""
	@# st
	@if [ ! -d /tmp/st ]; then git clone https://git.suckless.org/st /tmp/st; fi
	@cp $(CURDIR)/linux/st/config.h /tmp/st/
	@echo "st: Apply patches from linux/st/patches.txt, then run: cd /tmp/st && sudo make clean install"
	@echo ""
	@# dwm
	@if [ ! -d /tmp/dwm ]; then git clone https://git.suckless.org/dwm /tmp/dwm; fi
	@cp $(CURDIR)/linux/dwm/config.h /tmp/dwm/
	@echo "dwm: Apply patches from linux/dwm-patches/, then run: cd /tmp/dwm && sudo make clean install"
	@echo ""
	@# slstatus
	@if [ ! -d /tmp/slstatus ]; then git clone https://git.suckless.org/slstatus /tmp/slstatus; fi
	@cp $(CURDIR)/linux/slstatus/config.h /tmp/slstatus/
	@echo "slstatus: cd /tmp/slstatus && sudo make clean install"
	@echo ""
	@echo "All configs copied. Apply patches and build each tool."

nixos-%:
	@[ "$(OS)" = "macos" ] || { echo "macOS only"; exit 1; }
	./vms/nixos/setup.sh $*

openbsd-%:
	@[ "$(OS)" = "macos" ] || { echo "macOS only"; exit 1; }
	./vms/openbsd/setup.sh $*

void-%:
	@[ "$(OS)" = "macos" ] || { echo "macOS only"; exit 1; }
	./vms/void/setup.sh $*
