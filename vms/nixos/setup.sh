#!/bin/bash
# NixOS arm64 VM using QEMU
# For macOS with Apple Silicon

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration
NIXOS_CHANNEL="24.11"
ARCH="aarch64"
ISO_URL="https://channels.nixos.org/nixos-${NIXOS_CHANNEL}/latest-nixos-minimal-${ARCH}-linux.iso"
ISO_FILE="nixos-minimal-${ARCH}.iso"
DISK_IMAGE="nixos.qcow2"
DISK_SIZE="40G"
MEMORY="4G"
CPUS="4"
SSH_PORT="2224"

# UEFI firmware
UEFI_CODE_SRC=""
UEFI_VARS="edk2-aarch64-vars.fd"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[*]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

check_deps() {
    log "Checking dependencies..."
    command -v qemu-system-aarch64 >/dev/null || error "qemu not found. Run: make switch"
    command -v qemu-img >/dev/null || error "qemu-img not found"
    command -v expect >/dev/null || error "expect not found. Run: make switch"
}

download_iso() {
    if [ -f "$ISO_FILE" ]; then
        ISO_SIZE=$(stat -f%z "$ISO_FILE" 2>/dev/null || stat -c%s "$ISO_FILE" 2>/dev/null)
        if [ "$ISO_SIZE" -lt 800000000 ]; then
            warn "ISO file appears incomplete. Re-downloading..."
            rm -f "$ISO_FILE"
        else
            log "ISO already exists: $ISO_FILE"
            return
        fi
    fi
    log "Downloading NixOS ${NIXOS_CHANNEL} ${ARCH} minimal ISO..."
    curl -L -o "$ISO_FILE" "$ISO_URL"
}

setup_uefi() {
    QEMU_PATH=$(which qemu-system-aarch64)
    QEMU_REAL=$(readlink -f "$QEMU_PATH")
    QEMU_STORE_PATH=$(echo "$QEMU_REAL" | sed 's|/bin/qemu-system-aarch64||')
    UEFI_CODE_SRC="${QEMU_STORE_PATH}/share/qemu/edk2-aarch64-code.fd"

    if [ ! -f "$UEFI_CODE_SRC" ]; then
        UEFI_CODE_SRC=$(find /nix/store -name "edk2-aarch64-code.fd" -path "*qemu*" 2>/dev/null | head -1)
    fi

    if [ ! -f "$UEFI_CODE_SRC" ]; then
        error "UEFI firmware not found"
    fi
    log "Using UEFI firmware: $UEFI_CODE_SRC"

    if [ ! -f "$UEFI_VARS" ]; then
        log "Creating UEFI vars file..."
        dd if=/dev/zero of="$UEFI_VARS" bs=1M count=64 2>/dev/null
    fi
}

create_disk() {
    if [ -f "$DISK_IMAGE" ]; then
        warn "Disk image already exists: $DISK_IMAGE"
        read -p "Delete and recreate? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$DISK_IMAGE" "$UEFI_VARS"
        else
            return 1
        fi
    fi
    log "Creating ${DISK_SIZE} disk image..."
    qemu-img create -f qcow2 "$DISK_IMAGE" "$DISK_SIZE"
    rm -f "$UEFI_VARS"
}

# Generate a minimal NixOS configuration
generate_config() {
    cat << 'EOF'
# /mnt/etc/nixos/configuration.nix
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;

  time.timeZone = "UTC";

  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "nixos";
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # X11 + i3
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    displayManager.startx.enable = true;  # Manual startx, no login manager
  };

  # Allow password auth for initial setup
  users.users.root.initialPassword = "nixos";

  environment.systemPackages = with pkgs; [
    vim git htop curl wget
    alacritty      # terminal
    dmenu          # launcher
    i3status       # status bar
    feh            # wallpaper
  ];

  system.stateVersion = "24.11";
}
EOF
}

run_installer() {
    log "Starting automated NixOS installation..."
    log ""
    log "This will:"
    log "  1. Boot NixOS ISO"
    log "  2. Partition disk automatically"
    log "  3. Install NixOS with i3 + alacritty"
    log "  4. Shutdown when complete"
    log ""
    log "Installation takes ~10-15 minutes."
    log ""

    # Create expect script for full automation via console
    EXPECT_SCRIPT="/tmp/nixos-autoinstall-$$.exp"
    cat > "$EXPECT_SCRIPT" << 'EXPECTEOF'
#!/usr/bin/expect -f
set timeout 600

log_user 1

# Spawn QEMU
spawn {*}[lrange $argv 0 end]

# Wait for login prompt
expect {
    "nixos login:" {
        sleep 2
        send "root\r"
    }
    timeout { puts "Timeout waiting for login"; exit 1 }
}

# Wait for shell prompt
expect {
    "root@nixos" { sleep 1 }
    "#" { sleep 1 }
    timeout { puts "Timeout waiting for shell"; exit 1 }
}

# Run installation commands
send "echo '=== Partitioning disk ==='\r"
expect "#"
send "parted /dev/vda -- mklabel gpt\r"
expect "#"
send "parted /dev/vda -- mkpart ESP fat32 1MiB 512MiB\r"
expect "#"
send "parted /dev/vda -- set 1 esp on\r"
expect "#"
send "parted /dev/vda -- mkpart primary 512MiB 100%\r"
expect "#"

send "echo '=== Formatting ==='\r"
expect "#"
send "mkfs.fat -F 32 -n boot /dev/vda1\r"
expect "#"
send "mkfs.ext4 -L nixos /dev/vda2\r"
expect "#"

send "echo '=== Mounting ==='\r"
expect "#"
send "mount /dev/disk/by-label/nixos /mnt\r"
expect "#"
send "mkdir -p /mnt/boot\r"
expect "#"
send "mount /dev/disk/by-label/boot /mnt/boot\r"
expect "#"

send "echo '=== Generating config ==='\r"
expect "#"
send "nixos-generate-config --root /mnt\r"
expect "#"

send "echo '=== Writing configuration.nix ==='\r"
expect "#"

send "cat > /mnt/etc/nixos/configuration.nix << 'NIXCFG'\r"
send "{ config, pkgs, ... }:\r"
send "{\r"
send "  imports = \\[ ./hardware-configuration.nix \\];\r"
send "  boot.loader.systemd-boot.enable = true;\r"
send "  boot.loader.efi.canTouchEfiVariables = true;\r"
send "  networking.hostName = \"nixos-vm\";\r"
send "  networking.networkmanager.enable = true;\r"
send "  time.timeZone = \"UTC\";\r"
send "  users.users.user = {\r"
send "    isNormalUser = true;\r"
send "    extraGroups = \\[ \"wheel\" \"networkmanager\" \\];\r"
send "    initialPassword = \"nixos\";\r"
send "  };\r"
send "  services.openssh = {\r"
send "    enable = true;\r"
send "    settings.PermitRootLogin = \"yes\";\r"
send "  };\r"
send "  services.xserver = {\r"
send "    enable = true;\r"
send "    windowManager.i3.enable = true;\r"
send "    displayManager.startx.enable = true;\r"
send "  };\r"
send "  users.users.root.initialPassword = \"nixos\";\r"
send "  environment.systemPackages = with pkgs; \\[\r"
send "    vim git htop curl wget\r"
send "    alacritty dmenu i3status feh\r"
send "  \\];\r"
send "  system.stateVersion = \"24.11\";\r"
send "}\r"
send "NIXCFG\r"
expect "#"

send "echo '=== Installing NixOS (this takes a while) ==='\r"
expect "#"
set timeout 1800
send "nixos-install --no-root-passwd\r"
expect {
    "installation finished" { puts "\n\nInstallation successful!" }
    "#" { }
    timeout { puts "Installation timed out"; exit 1 }
}

send "echo '=== Done! Shutting down ==='\r"
expect "#"
send "poweroff\r"

expect eof
EXPECTEOF

    chmod +x "$EXPECT_SCRIPT"

    # Run expect with QEMU
    expect "$EXPECT_SCRIPT" \
        qemu-system-aarch64 \
        -machine virt,accel=hvf,highmem=on \
        -cpu host \
        -m "$MEMORY" \
        -smp "$CPUS" \
        -drive if=pflash,format=raw,file="$UEFI_CODE_SRC",readonly=on \
        -drive if=pflash,format=raw,file="$UEFI_VARS" \
        -drive file="$DISK_IMAGE",if=virtio,format=qcow2 \
        -cdrom "$ISO_FILE" \
        -boot d \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22 \
        -device virtio-balloon \
        -nographic \
        -serial mon:stdio || true

    rm -f "$EXPECT_SCRIPT"

    log ""
    log "Installation complete!"
    log "Run: make nixos-gui"
}

run_vm() {
    log "Starting NixOS VM..."
    log "SSH: ssh -p ${SSH_PORT} root@localhost"
    log "Exit: Ctrl+A then X"
    echo ""

    qemu-system-aarch64 \
        -machine virt,accel=hvf,highmem=on \
        -cpu host \
        -m "$MEMORY" \
        -smp "$CPUS" \
        -drive if=pflash,format=raw,file="$UEFI_CODE_SRC",readonly=on \
        -drive if=pflash,format=raw,file="$UEFI_VARS" \
        -drive file="$DISK_IMAGE",if=virtio,format=qcow2 \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22 \
        -device virtio-balloon \
        -nographic \
        -serial mon:stdio
}

run_vm_gui() {
    log "Starting NixOS VM (GUI)..."
    log "SSH: ssh -p ${SSH_PORT} root@localhost"
    log "Run 'startx' after login to launch i3"
    echo ""

    qemu-system-aarch64 \
        -machine virt,accel=hvf,highmem=on \
        -cpu host \
        -m "$MEMORY" \
        -smp "$CPUS" \
        -drive if=pflash,format=raw,file="$UEFI_CODE_SRC",readonly=on \
        -drive if=pflash,format=raw,file="$UEFI_VARS" \
        -drive file="$DISK_IMAGE",if=virtio,format=qcow2 \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22 \
        -device virtio-gpu-pci \
        -display cocoa \
        -device qemu-xhci \
        -device usb-kbd \
        -device usb-tablet \
        -device virtio-balloon
}

case "${1:-}" in
    install)
        check_deps
        download_iso
        create_disk || exit 0
        setup_uefi
        run_installer
        ;;
    run|start)
        check_deps
        setup_uefi
        [ -f "$DISK_IMAGE" ] || error "No disk image. Run: $0 install"
        run_vm
        ;;
    gui)
        check_deps
        setup_uefi
        [ -f "$DISK_IMAGE" ] || error "No disk image. Run: $0 install"
        run_vm_gui
        ;;
    ssh)
        ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost
        ;;
    config)
        generate_config
        ;;
    clean)
        log "Cleaning up VM files..."
        rm -f "$DISK_IMAGE" "$UEFI_VARS"
        log "Done. ISO preserved."
        ;;
    cleanall)
        log "Removing all files..."
        rm -f "$DISK_IMAGE" "$UEFI_VARS" "$ISO_FILE"
        log "Done."
        ;;
    *)
        echo "NixOS ${NIXOS_CHANNEL} ${ARCH} VM Manager"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  install   Download ISO and start installer"
        echo "  run       Start the VM (CLI mode)"
        echo "  gui       Start the VM with GUI (X11/i3)"
        echo "  ssh       SSH into the running VM (port ${SSH_PORT})"
        echo "  config    Print sample configuration.nix"
        echo "  clean     Remove disk image (keep ISO)"
        echo "  cleanall  Remove all files including ISO"
        echo ""
        echo "After install, run 'startx' to launch i3"
        echo "Default credentials: root:nixos  user:nixos"
        ;;
esac
