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
}

download_iso() {
    if [ -f "$ISO_FILE" ]; then
        ISO_SIZE=$(stat -f%z "$ISO_FILE" 2>/dev/null || stat -c%s "$ISO_FILE" 2>/dev/null)
        if [ "$ISO_SIZE" -lt 500000000 ]; then
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

  # Allow password auth for initial setup
  users.users.root.initialPassword = "nixos";

  environment.systemPackages = with pkgs; [
    vim git htop curl wget
  ];

  system.stateVersion = "24.11";
}
EOF
}

run_installer() {
    log "Starting NixOS installer..."
    log ""
    log "Installation steps:"
    log "  1. sudo -i"
    log "  2. parted /dev/vda -- mklabel gpt"
    log "  3. parted /dev/vda -- mkpart ESP fat32 1MiB 512MiB"
    log "  4. parted /dev/vda -- set 1 esp on"
    log "  5. parted /dev/vda -- mkpart primary 512MiB 100%"
    log "  6. mkfs.fat -F 32 -n boot /dev/vda1"
    log "  7. mkfs.ext4 -L nixos /dev/vda2"
    log "  8. mount /dev/disk/by-label/nixos /mnt"
    log "  9. mkdir -p /mnt/boot"
    log "  10. mount /dev/disk/by-label/boot /mnt/boot"
    log "  11. nixos-generate-config --root /mnt"
    log "  12. Edit /mnt/etc/nixos/configuration.nix (see below)"
    log "  13. nixos-install"
    log "  14. reboot"
    log ""
    log "Minimal configuration.nix:"
    log "----------------------------------------"
    generate_config
    log "----------------------------------------"
    log ""
    log "SSH: ssh -p ${SSH_PORT} root@localhost (after install)"
    log "Exit VM: Ctrl+A then X"
    log ""

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
        -serial mon:stdio
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
        echo "  run       Start the VM (after installation)"
        echo "  ssh       SSH into the running VM (port ${SSH_PORT})"
        echo "  config    Print sample configuration.nix"
        echo "  clean     Remove disk image (keep ISO)"
        echo "  cleanall  Remove all files including ISO"
        echo ""
        echo "Default credentials: root:nixos  user:nixos"
        ;;
esac
