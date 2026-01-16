# Dotfiles

Cross-platform Nix configuration for **macOS** (nix-darwin) and **Linux** (Home Manager).

## Quick Start

**macOS:**
```bash
./setup.sh
```

**Linux:**
```bash
curl -L https://install.determinate.systems/nix | sh -s -- install
make install
```

## Commands

```bash
make            # Show help
make install    # First-time installation
make switch     # Rebuild configuration
make update     # Update flake inputs
make upgrade    # Update + switch
make clean      # Garbage collect
make check      # Verify installation
```

## macOS Window Management

This setup creates a tiling window manager experience on macOS using:

- **AeroSpace** - Tiling window manager (i3/bspwm-like)
- **SketchyBar** - Custom status bar (replaces menu bar)
- **JankyBorders** - Active window border highlighting

### AeroSpace Keybindings

| Keys | Action |
|------|--------|
| `alt + h/j/k/l` | Focus window (left/down/up/right) |
| `alt + shift + h/j/k/l` | Move window |
| `alt + 1-9` | Switch workspace |
| `alt + shift + 1-9` | Move window to workspace |
| `alt + enter` | Open Ghostty terminal |
| `alt + q` | Close window |
| `alt + f` | Toggle fullscreen |
| `alt + shift + space` | Toggle floating |
| `alt + /` | Cycle layouts (tiles) |
| `alt + ,` | Cycle layouts (accordion) |
| `alt + -/=` | Resize window |
| `alt + tab` | Previous workspace |
| `alt + shift + ;` | Service mode (r=reset, esc=reload) |

### First Run

After installation, start AeroSpace manually:
```bash
open -a AeroSpace
```

It will auto-start on subsequent logins.

## What's Included

### CLI Tools (all platforms)

| Category | Tools |
|----------|-------|
| Editor | neovim |
| Shell | fish, starship, zoxide, direnv |
| Git | git, lazygit, delta, gh, tig |
| Search | ripgrep, fd, fzf |
| View | eza, bat, glow, tree |
| System | htop, btop, dust, tmux |
| Other | jq, tldr, wget, rustup |

### macOS Apps (via Homebrew)

| Category | Apps |
|----------|------|
| Window Manager | AeroSpace, SketchyBar, Borders |
| Browsers | Brave, Firefox |
| Communication | Telegram, Slack, Zoom, WhatsApp, Signal |
| Productivity | 1Password, Caffeine, Obsidian |
| Development | Ghostty, Zed, GitHub Desktop, Claude |
| Media | Spotify |
| Utilities | UTM |

### Fonts

JetBrains Mono, Fira Code, Hack (all Nerd Font variants)

## Shell Abbreviations

```
g=git  ga=git add  gc=git commit  gp=git push  gs=git status  gd=git diff
lg=lazygit  v=nvim  t=tmux  ta=tmux attach
ls=eza  ll=eza -l  la=eza -la  lt=eza --tree  cat=bat  cd=z
```

## Configuration

Edit `flake.nix` to customize:

```nix
username = "your-username";
gitName = "Your Name";
gitEmail = "your@email.com";
```

## Structure

```
flake.nix           Main configuration
Makefile            Build commands
setup.sh            macOS bootstrap script
modules/
  darwin.nix        macOS system settings, Homebrew, launchd services
  home.nix          Home Manager entry point
  packages.nix      CLI packages
  shell.nix         Fish shell, zoxide, bat, fzf, eza, direnv
  starship.nix      Prompt configuration
  git.nix           Git and lazygit config
  neovim.nix        Neovim configuration
  tmux.nix          Tmux configuration
  terminal.nix      Ghostty and Zed settings
  wm.nix            AeroSpace, SketchyBar, JankyBorders configs
linux/
  st/               Suckless terminal config.h (Nord, recommended patches)
  slstatus/         Status bar config.h
  dwm-patches/      Custom dwm patches
  xorg/             Xresources (Nord), xinitrc, fonts.conf
  dunst/            Notification daemon (Nord theme)
  picom/            Compositor (shadows, transparency, rounded corners)
  rofi/             App launcher (Nord theme)
  gtk-3.0/          GTK3 settings (Nordic theme)
  parcellite/       Clipboard manager
vms/                VM scripts (NixOS, OpenBSD, Void)
wallpapers/         Desktop wallpapers
```

## Theme

Nord color scheme throughout (SketchyBar, window borders, terminal).

## Linux (dwm setup)

A suckless-style desktop with dwm, featuring Nord theme throughout.

### Components

| Component | Purpose |
|-----------|---------|
| **dwm** | Tiling window manager |
| **slstatus** | Status bar |
| **picom** | Compositor (shadows, transparency, rounded corners) |
| **rofi** | App launcher (replaces dmenu) |
| **dunst** | Notifications |
| **feh** | Wallpaper |
| **redshift** | Night light |

### Installation

On **Void Linux**, configs are auto-installed with `make switch`.

For other distros:
```bash
make linux-dotfiles
```

### Manual Steps

**Suckless software** (copy config.h, apply patches, rebuild):
1. `st` - terminal (see `linux/st/patches.txt` for recommended patches)
2. `dwm` - apply patches from `linux/dwm-patches/`
3. `slstatus` - status bar

**Theming:**
4. Install [Nordic GTK theme](https://github.com/EliverLara/Nordic)
5. Install Papirus icons: `papirus-icon-theme`

### Environment Variables

Set in your shell config to customize:
```bash
export LOCATION="-34.60:-58.38"  # lat:lon for redshift
```

## VMs (macOS only)

```bash
make nixos-{install,run,gui,ssh,clean}    # port 2224
make openbsd-{install,run,ssh,clean}      # port 2222
make void-{install,run,gui,ssh,clean}     # port 2223
```

VM credentials are for local testing only.

## References

**Nix:**
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://github.com/nix-community/home-manager)

**macOS:**
- [AeroSpace](https://github.com/nikitabobko/AeroSpace)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar)
- [JankyBorders](https://github.com/FelixKratz/JankyBorders)

**Linux:**
- [st](https://st.suckless.org/) - terminal
- [dwm](https://dwm.suckless.org/) - window manager
- [slstatus](https://tools.suckless.org/slstatus/) - status bar
- [picom](https://github.com/yshui/picom) - compositor
- [rofi](https://github.com/davatorium/rofi) - app launcher
- [dunst](https://github.com/dunst-project/dunst) - notifications
- [Nordic GTK Theme](https://github.com/EliverLara/Nordic)
- [Nord Theme](https://www.nordtheme.com/)
