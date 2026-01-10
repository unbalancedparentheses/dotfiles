# Dotfiles

Cross-platform configuration for **macOS** (nix-darwin) and **Linux** (Home Manager).

## Quick Start

### macOS
```bash
./setup.sh
```

### Linux (any distro with Nix)
```bash
# Install Nix first (if not installed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Install Home Manager and apply configuration
make install
```

## Daily Usage

```bash
make switch      # Rebuild and activate configuration
make update      # Update flake inputs
make upgrade     # Update and rebuild
make search      # Search for packages
make info        # Show detected OS
```

## What's Included

### Shared (macOS + Linux)

**CLI Tools:**
- **Editor**: neovim
- **Shell**: fish with starship prompt
- **Git**: git, lazygit, delta, gh, tig
- **Modern CLI**: eza, bat, ripgrep, fd, fzf, zoxide, jq, tldr
- **System**: htop, btop, dust, tree, wget, tmux

**Shell Configuration:**
- Fish shell with abbreviations (cargo, pyenv paths configured)
- Starship prompt with git integration
- Zoxide for smart directory jumping

### macOS Only

**Homebrew Casks:**
- Browsers: Brave, Firefox
- Communication: Telegram, Slack, Zoom, WhatsApp, Signal
- Productivity: 1Password, Notion, Caffeine, Obsidian
- Development: Ghostty, GitHub Desktop, Zed, Claude
- Media: Spotify
- Utilities: UTM

**macOS Preferences:**
- Dock: auto-hide, no recent apps
- Finder: show all files and extensions
- Keyboard: fast repeat, no autocorrect
- Battery percentage in menu bar

### Linux Only

**Fonts** (via Home Manager):
- JetBrains Mono, Fira Code, Hack (Nerd Fonts)

**Manual dotfiles** (for non-NixOS):
```bash
make linux-dotfiles  # Symlink xorg, dunst, parcellite configs
make dwm             # Build dwm with patches
make slstatus        # Build slstatus
```

## Configuration

Edit `flake.nix` to customize:

```nix
# User settings
username = "your-username";
gitName = "Your Name";
gitEmail = "your@email.com";

# System architecture
darwinSystem = "aarch64-darwin";  # or x86_64-darwin
linuxSystem = "x86_64-linux";     # or aarch64-linux
```

## Fish Abbreviations

| Abbr | Command |
|------|---------|
| `g` | `git` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gs` | `git status` |
| `lg` | `lazygit` |
| `v` | `nvim` |
| `t` | `tmux` |
| `ls` | `eza --icons` |
| `cat` | `bat` |
| `cd` | `z` (zoxide) |

## VMs (macOS only)

### OpenBSD
```bash
make openbsd-install  # Download and install OpenBSD
make openbsd-run      # Start the VM
make openbsd-ssh      # SSH into VM
make openbsd-clean    # Remove VM files
```

### Void Linux
```bash
make void-install     # Download and install Void
make void-run         # Start the VM
make void-gui         # Start with GUI
make void-ssh         # SSH into VM
make void-clean       # Remove VM files
```

## Linux Tips

### WiFi Setup (wpa_supplicant)
```bash
wpa_supplicant -B -i wlp0s20f3 -c /etc/wpa_supplicant/wpa_supplicant.conf
wpa_cli
> scan
> scan_results
> add_network
0
> set_network 0 ssid "MYSSID"
> set_network 0 psk "passphrase"
> enable_network 0
> save_config
> quit
```

### Sound Fix (Intel HDA)
```bash
echo 'GRUB_CMDLINE_LINUX="snd_hda_intel.dmic_detect=0"' >> /etc/default/grub
update-grub
```

### Better Firefox Fonts
In `about:config`:
```
gfx.font_rendering.fontconfig.max_generic_substitutions = 127
```

## File Structure

```
.
├── flake.nix          # Main Nix configuration
├── flake.lock         # Locked dependencies
├── Makefile           # Build commands
├── setup.sh           # macOS setup script
├── openbsd-vm/        # OpenBSD VM automation
├── void-vm/           # Void Linux VM automation
├── wallpapers/        # Desktop wallpapers
├── xorg/              # X.org configs (Linux)
├── dunst/             # Notification daemon config
├── dwm-patches/       # DWM patches
└── parcellite/        # Clipboard manager config
```

## References

- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Nixology](https://www.youtube.com/playlist?list=PLRGI9KQ3_HP_OFRG6R-p4iFgMSK1t5BHs) - YouTube playlist
- [nix.dev](https://nix.dev/)
