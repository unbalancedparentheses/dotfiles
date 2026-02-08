# Dotfiles

Cross-platform Nix configuration for macOS and Linux.

## Installation

```bash
git clone https://github.com/unbalancedparentheses/dotfiles ~/projects/dotfiles
cd ~/projects/dotfiles
make configure  # Set your username and git credentials
make            # Install everything
```

On macOS, this installs Xcode CLI tools, Nix, and Homebrew automatically if missing.

## Commands

| Command | Description |
|---------|-------------|
| `make` | Install/update everything |
| `make configure` | Interactive setup (username, git name/email) |
| `make check` | Verify installation |
| `make clean` | Garbage collect Nix store |

## What's Included

### Editors
- **Neovim** with LSP, Treesitter, Telescope, and Tokyo Night theme
- **Emacs** with evil-mode, eglot, vertico, and corfu

### Shell
- **Fish** as default shell with abbreviations
- **Starship** prompt
- **Atuin** for shell history
- **Zoxide** for smart cd
- **Direnv** for per-directory environments

### CLI Tools
| Tool | Description |
|------|-------------|
| ripgrep, fd, fzf | Fast search |
| eza, bat, glow | Better ls/cat/markdown |
| lazygit, delta, gh | Git utilities |
| btop, dust | System monitoring |
| tmux | Terminal multiplexer |
| just, hyperfine, tokei | Dev utilities |

### Languages (via mise)
Rust, Go, Python, Node, Erlang, Elixir, Zig, Gleam

## macOS

### Window Management
- **AeroSpace** - Tiling window manager (i3-like)
- **SketchyBar** - Custom status bar
- **JankyBorders** - Window border highlighting

Start AeroSpace after first install: `open -a AeroSpace`

### Key Bindings

| Keys | Action |
|------|--------|
| `alt + h/j/k/l` | Focus window |
| `alt + shift + h/j/k/l` | Move window |
| `alt + 1-9` | Switch workspace |
| `alt + shift + 1-9` | Move to workspace |
| `alt + enter` | Open terminal |
| `alt + q` | Close window |
| `alt + f` | Fullscreen |

### Apps (Homebrew)
Brave, Firefox, Ghostty, Zed, Slack, Telegram, WhatsApp, Signal, 1Password, Obsidian, Spotify

## Linux

Suckless-style desktop with dwm, st, and slstatus. All built automatically from configs in `linux/`.

### Components
- **dwm** - Window manager
- **st** - Terminal
- **slstatus** - Status bar
- **rofi** - App launcher
- **picom** - Compositor
- **dunst** - Notifications

Theme: Nord throughout (GTK, terminal, notifications).

## VMs (macOS only)

QEMU-based VMs for testing on Apple Silicon.

```bash
make openbsd-install    # Automated OpenBSD install (port 2222)
make nixos-install      # Automated NixOS install (port 2224)
make void-install       # Void Linux install (port 2223)

make openbsd-run        # Start VM (serial console)
make nixos-gui          # Start VM with GUI
make openbsd-ssh        # SSH into running VM
```

## Structure

```
flake.nix           # Main config (username, git credentials at top)
Makefile            # Build commands
modules/
  darwin.nix        # macOS settings, Homebrew
  home.nix          # Home Manager entry
  packages.nix      # CLI packages
  shell.nix         # Fish, zoxide, fzf
  neovim.nix        # Neovim config
  emacs.nix         # Emacs config
  git.nix           # Git config
  tmux.nix          # Tmux config
  terminal.nix      # Ghostty, Zed
  linux.nix         # Linux desktop (rofi, picom, dunst)
  lsp.nix           # Language servers
linux/              # Suckless configs (dwm, st, slstatus)
vms/                # VM automation scripts
  lib.sh            # Shared VM utilities
  openbsd/          # OpenBSD VM
  nixos/            # NixOS VM
  void/             # Void Linux VM
wallpapers/         # Desktop wallpapers
```

## Configuration

Edit `flake.nix` or run `make configure`:

```nix
username = "your-username";
gitName = "Your Name";
gitEmail = "your@email.com";
```

## Shell Abbreviations

```
g=git  ga=git add  gc=git commit  gp=git push  gs=git status
lg=lazygit  v=nvim  t=tmux  ls=eza  cat=bat  cd=z
```
