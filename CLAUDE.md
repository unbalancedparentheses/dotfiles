# Dotfiles

Cross-platform Nix configuration for macOS (nix-darwin) and Linux (Home Manager).

## Commands

- `make` — Install/update everything
- `make clean` — Nix garbage collect
- `make check` — Verify installation

## Structure

```
flake.nix               # Main config (username, gitName, gitEmail at top)
Makefile                # Build commands
modules/
  darwin.nix            # macOS settings, Homebrew casks, defaults
  home.nix              # Home Manager entry point
  packages.nix          # CLI packages (shared + platform-specific)
  shell.nix             # Fish shell, zoxide, fzf, eza, direnv, atuin
  starship.nix          # Prompt config
  git.nix               # Git and lazygit config
  neovim.nix            # Neovim with LSP, Treesitter, Telescope
  emacs.nix             # Emacs with evil, eglot, vertico, corfu
  tmux.nix              # Tmux config
  terminal.nix          # Ghostty and Zed settings
  ssh.nix               # SSH config and host aliases
  lsp.nix               # Language servers (shared by editors)
  linux.nix             # Linux desktop (dwm, rofi, picom, dunst)
  theme.nix             # Color scheme definitions
  secrets.nix.template  # Template for API keys (copy to secrets.nix)
linux/                  # Suckless configs (dwm, st, slstatus config.h)
vms/                    # VM automation (macOS only)
  lib.sh                # Shared VM functions
  openbsd/              # OpenBSD VM (port 2222)
  nixos/                # NixOS VM (port 2224)
  void/                 # Void Linux VM (port 2223)
wallpapers/             # Desktop wallpapers
```

## VMs (macOS only)

QEMU with HVF on Apple Silicon. SSH aliases configured: `ssh openbsd-vm`, `ssh nixos-vm`, `ssh void-vm`

```bash
make openbsd-install    # Automated install
make openbsd-run        # Start VM (serial)
make openbsd-ssh        # SSH into VM

make nixos-install / nixos-run / nixos-gui / nixos-ssh
make void-install / void-run / void-gui / void-ssh
```

Credentials: `root:openbsd`, `root:nixos`, `root:voidlinux`

## Conventions

- Edit `flake.nix` to change username, git name/email
- Nix manages CLI tools, Homebrew manages macOS GUI apps
- Languages via mise: rust, go, python, node, erlang, elixir, zig, gleam
- Secrets go in `modules/secrets.nix` (gitignored)
- VM artifacts (*.qcow2, *.iso) are gitignored

## Code Style

- Nix modules use 2-space indent
- Shell scripts use `set -e` and source `lib.sh` for shared functions
- Prefer Home Manager options over raw config files
- Keep darwin.nix for macOS-only, linux.nix for Linux-only
