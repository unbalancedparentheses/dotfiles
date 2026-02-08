# Dotfiles

Cross-platform Nix configuration for macOS (nix-darwin) and Linux (Home Manager).

## Key Commands

- `make` — Install/update everything (nix-darwin on macOS, home-manager on Linux)
- `make clean` — Nix garbage collect
- `make check` — Verify installation

## Structure

- `flake.nix` — Main configuration (username, git name/email at top)
- `Makefile` — Build commands
- `modules/` — Nix modules (shell, git, neovim, emacs, tmux, terminal, wm, etc.)
- `linux/` — Suckless configs (dwm, st, slstatus)
- `vms/` — VM automation scripts (macOS only, QEMU + Apple Silicon)
- `wallpapers/` — Desktop wallpapers

## VMs (macOS only)

All VMs use QEMU with HVF acceleration on Apple Silicon. Each has a `setup.sh` with the same interface.

### OpenBSD (port 2222)

```bash
cd vms/openbsd
./setup.sh install      # Download ISO + fully automated install (~15 min)
./setup.sh run          # Boot the VM (serial console, Ctrl+A then X to exit)
./setup.sh ssh          # SSH into running VM
./setup.sh provision    # Install packages (vim, git, curl, wget, htop), setup doas + SSH keys
./setup.sh clean        # Remove disk image (keep ISO)
```

Or from the repo root: `make openbsd-{install,run,ssh,clean}`

Credentials: `root:openbsd` / `user:openbsd`

### NixOS (port 2224)

```bash
cd vms/nixos
./setup.sh install      # Download ISO + automated install
./setup.sh run          # Boot the VM (serial console)
./setup.sh gui          # Boot with GUI (VNC/display)
./setup.sh ssh          # SSH into running VM
./setup.sh clean        # Remove disk image
```

Or from the repo root: `make nixos-{install,run,gui,ssh,clean}`

### Void Linux (port 2223)

```bash
cd vms/void
./setup.sh install      # Download ISO + automated install
./setup.sh run          # Boot the VM (serial console)
./setup.sh gui          # Boot with GUI (VNC/display)
./setup.sh ssh          # SSH into running VM
./setup.sh clean        # Remove disk image
```

Or from the repo root: `make void-{install,run,gui,ssh,clean}`

## Conventions

- Packages are managed via Nix (system-level on macOS, home-manager on Linux)
- macOS GUI apps are managed via Homebrew casks (declared in `modules/darwin.nix`)
- Languages are managed via mise (rust, go, python, node, erlang, elixir, zig, gleam)
- VM disk images, ISOs, and build artifacts are gitignored
