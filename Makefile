.PHONY: switch install update upgrade check build dry-run clean generations rollback search \
        update-user openbsd-install openbsd-run openbsd-ssh openbsd-clean \
        void-install void-run void-gui void-headless void-ssh void-clean \
        xorg dunst dwm parcellite linux-dotfiles

# Source directory for dotfiles
SOURCE := $(CURDIR)

# Detect OS and user
UNAME := $(shell uname -s)
USERNAME := $(shell whoami)
ifeq ($(UNAME),Darwin)
    OS := macos
    NIX := /nix/var/nix/profiles/default/bin/nix
else
    OS := linux
    NIX := nix
endif

# Update username in flake.nix to current user
update-user:
	@sed -i '' 's/username = "[^"]*";/username = "$(USERNAME)";/' flake.nix

# =============================================================================
# Main commands (auto-detect OS)
# =============================================================================

# Rebuild and switch to new configuration
switch: update-user
ifeq ($(OS),macos)
	sudo -H $(NIX) run nix-darwin -- switch --flake ".#default"
else
	home-manager switch --flake .#linux -b backup
endif

# First-time install
install: update-user
ifeq ($(OS),macos)
	sudo -H $(NIX) run nix-darwin -- switch --flake ".#default"
else
	nix run home-manager -- switch --flake .#linux -b backup
endif

# Update all flake inputs
update:
	$(NIX) flake update

# Update and rebuild
upgrade: update switch

# Check configuration without building
check:
	$(NIX) flake check

# Build without switching
build:
ifeq ($(OS),macos)
	$(NIX) run nix-darwin -- build --flake ".#default"
else
	home-manager build --flake .#linux
endif

# Show what would change
dry-run:
ifeq ($(OS),macos)
	$(NIX) run nix-darwin -- build --flake ".#default" --dry-run
else
	home-manager build --flake .#linux --dry-run
endif

# Garbage collect old generations
clean:
ifeq ($(OS),macos)
	sudo $(NIX) store gc
else
	$(NIX) store gc
endif

# List generations
generations:
ifeq ($(OS),macos)
	$(NIX) run nix-darwin -- --list-generations
else
	home-manager generations
endif

# Rollback to previous generation
rollback:
ifeq ($(OS),macos)
	sudo -H $(NIX) run nix-darwin -- --rollback
else
	@echo "Use: home-manager generations  # to list"
	@echo "Then: home-manager switch --flake .#linux/<generation-id>"
endif

# Search for a package
search:
	@read -p "Package name: " pkg; $(NIX) search nixpkgs $$pkg

# Show detected OS
info:
	@echo "Detected OS: $(OS)"
	@echo "Nix: $(NIX)"

# =============================================================================
# OpenBSD VM (macOS only)
# =============================================================================

openbsd-install:
ifeq ($(OS),macos)
	./openbsd-vm/setup.sh install
else
	@echo "OpenBSD VM is only available on macOS"
endif

openbsd-run:
ifeq ($(OS),macos)
	./openbsd-vm/setup.sh run
else
	@echo "OpenBSD VM is only available on macOS"
endif

openbsd-ssh:
ifeq ($(OS),macos)
	./openbsd-vm/setup.sh ssh
else
	@echo "OpenBSD VM is only available on macOS"
endif

openbsd-clean:
ifeq ($(OS),macos)
	./openbsd-vm/setup.sh clean
else
	@echo "OpenBSD VM is only available on macOS"
endif

# =============================================================================
# Void Linux VM (macOS only) - with GUI support
# =============================================================================

void-install:
ifeq ($(OS),macos)
	./void-vm/setup.sh install
else
	@echo "Void VM is only available on macOS"
endif

void-run:
ifeq ($(OS),macos)
	./void-vm/setup.sh run
else
	@echo "Void VM is only available on macOS"
endif

void-gui:
ifeq ($(OS),macos)
	./void-vm/setup.sh gui
else
	@echo "Void VM is only available on macOS"
endif

void-headless:
ifeq ($(OS),macos)
	./void-vm/setup.sh headless
else
	@echo "Void VM is only available on macOS"
endif

void-ssh:
ifeq ($(OS),macos)
	./void-vm/setup.sh ssh
else
	@echo "Void VM is only available on macOS"
endif

void-clean:
ifeq ($(OS),macos)
	./void-vm/setup.sh clean
else
	@echo "Void VM is only available on macOS"
endif

# =============================================================================
# Linux dotfile symlinks (for non-NixOS Linux systems)
# =============================================================================

# Symlink all Linux dotfiles
linux-dotfiles: xorg dunst parcellite
	@echo "Linux dotfiles installed"

# X.org configuration
xorg:
	ln -sfn $(SOURCE)/xorg/Xresources ~/.Xresources
	ln -sfn $(SOURCE)/xorg/fonts.conf ~/.fonts.conf
	ln -sfn $(SOURCE)/xorg/xinitrc ~/.xinitrc

# Dunst notification daemon
dunst:
	mkdir -p ~/.config
	ln -sfn $(SOURCE)/dunst ~/.config/dunst

# Parcellite clipboard manager
parcellite:
	mkdir -p ~/.config
	ln -sfn $(SOURCE)/parcellite ~/.config/parcellite

# Build and install dwm with patches
dwm:
	rm -rf tmp-dwm
	git clone https://git.suckless.org/dwm tmp-dwm
	cd tmp-dwm && \
		git checkout 6.1 && \
		patch < ../dwm-patches/dwm-6.1-unbalanced.diff && \
		patch < ../dwm-patches/dwm-6.1-systray.diff && \
		sudo make clean install
	rm -rf tmp-dwm

# Build and install slstatus
slstatus:
	rm -rf slstatus
	git clone https://git.suckless.org/slstatus
	cd slstatus && sudo make clean install
