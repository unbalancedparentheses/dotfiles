# OpenBSD VM on macOS

Two options for running OpenBSD on Apple Silicon Macs:
- **UTM** (GUI) - Easier setup, recommended for most users
- **QEMU** (CLI) - Better for automation and scripting

## Option 1: UTM (GUI)

UTM provides a user-friendly interface for running VMs on macOS.

### Install UTM

UTM is included in the nix-darwin config (via Homebrew casks), or install manually:
```bash
brew install --cask utm
```

### Download OpenBSD ISO

```bash
curl -LO https://cdn.openbsd.org/pub/OpenBSD/7.8/arm64/install78.iso
```

### Create VM in UTM

1. Launch UTM → **Create a New Virtual Machine**
2. Select **Virtualize** → **Other**
3. **Boot ISO Image**: Select `install78.iso`
4. **Memory**: 2048 MB (or more)
5. **CPU Cores**: 2 (or more)
6. **Storage**: 20 GB (or more)
7. **Shared Directory**: Optional, for file transfers
8. **Name**: `OpenBSD` → **Save**

### Configure VM Settings

Before booting, edit the VM settings:

1. **QEMU → Display**: Change to `virtio-ramfb`
2. **System → Force Multicore**: Enable
3. **Network → Emulated Network Card**: Set to `virtio-net-pci`

### Install OpenBSD

1. Start the VM
2. At `boot>` prompt, just press Enter (or type `boot`)
3. Follow the installer:
   - `(I)nstall` → Enter
   - Keyboard layout → Enter (default)
   - Hostname → Enter (or set custom)
   - Network interface → `vio0`
   - IPv4 → `dhcp`
   - Root password → set one
   - Start sshd → `yes`
   - X Window System → `no` (unless needed)
   - Setup user → create one
   - Timezone → your choice
   - Root disk → `sd0`
   - Use whole disk → `W`
   - Auto layout → `A`
   - Location of sets → `http`
   - HTTP Server → `cdn.openbsd.org`
   - Server directory → `pub/OpenBSD/7.8/arm64`
   - Select sets → Enter (default)

4. When done, select **Halt**
5. In UTM: Edit VM → Remove ISO from CD/DVD
6. Start VM again → boots into installed OpenBSD

### Troubleshooting UTM

| Problem | Solution |
|---------|----------|
| Black screen / no display | Change display to `virtio-ramfb` in QEMU settings |
| Keyboard/mouse not working | Add Serial device, use `set tty com0` at boot prompt |
| No network | Ensure network card is `virtio-net-pci` |
| VM won't boot after install | Remove ISO from CD/DVD drive |
| Slow performance | Enable "Force Multicore" in System settings |

---

## Option 2: QEMU (CLI)

For automation and scripting, use QEMU directly.

### Quick Start

```bash
# Ensure qemu is installed (from nix-darwin config)
make switch  # from parent directory

# Install OpenBSD
./setup.sh install

# Start the VM (after installation)
./setup.sh run

# SSH into the VM
./setup.sh ssh
```

### Installation Process

When you run `./setup.sh install`:

1. **At the boot prompt**, press Enter or type `boot`
2. Follow the installer prompts (same as UTM above)
3. After installation completes, select **Halt**
4. Exit QEMU: `Ctrl+A` then `X`
5. Run `./setup.sh run` to boot the installed system

### Commands

| Command | Description |
|---------|-------------|
| `./setup.sh install` | Download ISO and install OpenBSD |
| `./setup.sh run` | Start the VM |
| `./setup.sh ssh` | SSH into running VM (port 2222) |
| `./setup.sh clean` | Remove disk image (keep ISO) |
| `./setup.sh cleanall` | Remove all files |

### Configuration

Edit `setup.sh` to change:

```bash
OPENBSD_VERSION="7.6"    # OpenBSD version
DISK_SIZE="20G"          # Virtual disk size
MEMORY="2G"              # RAM
CPUS="2"                 # CPU cores
SSH_PORT="2222"          # Host SSH port
```

### Troubleshooting QEMU

| Problem | Solution |
|---------|----------|
| No output / hangs | Already using `-nographic -serial mon:stdio` |
| UEFI not found | Run `make switch` to ensure qemu is installed |
| Network not working | Check `virtio-net-pci` device is configured |
| Can't SSH | Ensure VM is running, use port 2222 |

---

## Post-Installation Setup

After installing OpenBSD:

```bash
# SSH into VM
ssh -p 2222 root@localhost  # QEMU
# or use UTM's terminal

# Update system
pkg_add -u

# Install useful packages
pkg_add vim git curl wget htop

# Change default passwords!
passwd root
passwd user
```

## Networking

- **UTM**: Uses shared networking (NAT) by default
- **QEMU**: SSH forwarded `localhost:2222` → VM port 22
- Both can access internet through host

## Tips

### Resize disk
```bash
# QEMU
qemu-img resize openbsd.qcow2 +10G

# Inside VM
growfs sd0
```

### Snapshots (QEMU only)
```bash
qemu-img snapshot -c clean openbsd.qcow2  # create
qemu-img snapshot -a clean openbsd.qcow2  # restore
```

### Shared folders (UTM)
1. Add shared directory in VM settings
2. In OpenBSD: `mount_9p share /mnt`

## Files

| File | Purpose |
|------|---------|
| `setup.sh` | QEMU automation script |
| `install.conf` | Autoinstall response file (optional) |
| `disklabel.auto` | Disk partitioning template (optional) |
| `openbsd.qcow2` | Virtual disk (created by QEMU) |
| `install78.iso` | Installation media (downloaded) |

## References

- [Setup an OpenBSD VM on macOS Using UTM](https://btxx.org/posts/openbsd-mac-utm/)
- [Running OpenBSD 7.4 under UTM on macOS](https://blog.adamretter.org.uk/running-openbsd-74-under-utm/)
- [UTM GitHub Discussions - OpenBSD](https://github.com/utmapp/UTM/discussions/5643)
- [OpenBSD FAQ - Installation](https://www.openbsd.org/faq/faq4.html)
- [OpenBSD autoinstall(8)](https://man.openbsd.org/autoinstall)
