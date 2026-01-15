# Dotfiles

Cross-platform config for **macOS** (nix-darwin) and **Linux** (Home Manager).

## Setup

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

**Linux dotfiles** (non-NixOS):
```bash
make linux-dotfiles   # Symlink xorg, dunst, parcellite
```

**VMs** (macOS only):
```bash
make nixos-{install,run,ssh,clean}     # port 2224
make openbsd-{install,run,ssh,clean}   # port 2222
make void-{install,run,gui,ssh,clean}  # port 2223
```

> **Note:** VM credentials (root:nixos, etc.) are for local testing only. Do not use in production.

## What's Included

| Category | Packages |
|----------|----------|
| Editor | neovim |
| Shell | fish, starship, zoxide |
| Git | git, lazygit, delta, gh, tig |
| CLI | eza, bat, ripgrep, fd, fzf, jq, tldr |
| System | htop, btop, dust, tree, wget, tmux |

**macOS extras:** Brave, Firefox, Telegram, Slack, 1Password, Ghostty, Zed, Claude, Spotify, UTM

## Configuration

Edit `flake.nix`:
```nix
username = "your-username";
gitName = "Your Name";
gitEmail = "your@email.com";
```

## Fish Abbreviations

`g`=git, `ga`=git add, `gc`=git commit, `gp`=git push, `gs`=git status, `lg`=lazygit, `v`=nvim, `t`=tmux, `ls`=eza, `cat`=bat, `cd`=zoxide

## Structure

```
flake.nix       Main Nix configuration
Makefile        Build commands
setup.sh        macOS bootstrap
linux/          Linux configs (xorg, dunst, parcellite, dwm-patches)
vms/            VM scripts (nixos, openbsd, void)
wip/            Work in progress
wallpapers/     Desktop wallpapers
```

## References

- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Nixology](https://www.youtube.com/playlist?list=PLRGI9KQ3_HP_OFRG6R-p4iFgMSK1t5BHs)
