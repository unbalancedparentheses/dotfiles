#!/bin/bash
# Void Linux arm64 VM with GUI (Wayland/Sway) using QEMU
# For macOS with Apple Silicon

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration
ARCH="aarch64"
ISO_BASE_URL="https://repo-default.voidlinux.org/live/current"
ISO_FILE="void-live-${ARCH}.iso"
DISK_IMAGE="void.qcow2"
DISK_SIZE="40G"
MEMORY="4G"
CPUS="4"
SSH_PORT="2223"

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
        if [ "$ISO_SIZE" -lt 300000000 ]; then
            warn "ISO file appears incomplete. Re-downloading..."
            rm -f "$ISO_FILE"
        else
            log "ISO already exists: $ISO_FILE"
            return
        fi
    fi
    log "Finding latest Void Linux ${ARCH} ISO..."
    ISO_NAME=$(curl -s "${ISO_BASE_URL}/" | grep -o "void-live-${ARCH}-[0-9]*-base\.iso" | head -1)
    if [ -z "$ISO_NAME" ]; then
        error "Could not find ISO. Check ${ISO_BASE_URL}/"
    fi
    ISO_URL="${ISO_BASE_URL}/${ISO_NAME}"
    log "Downloading: $ISO_NAME"
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

# Run installer (CLI mode)
run_installer() {
    log "Starting Void Linux installer (CLI)..."
    log "Default live credentials: root (no password) or anon/voidlinux"
    log ""
    log "After booting:"
    log "  1. Run: void-installer"
    log "  2. Complete installation"
    log "  3. Select 'Shutdown' at the end"
    log ""
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

    log ""
    log "Base installation complete. Now installing packages..."
    log "Starting VM for post-install setup..."

    # Start VM in background for post-install
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
        -serial mon:stdio &

    QEMU_PID=$!

    log "Waiting for VM to boot (30 seconds)..."
    sleep 30

    log "Installing packages from packages.txt..."
    PACKAGES=$(grep -v '^#' "${SCRIPT_DIR}/packages.txt" | grep -v '^$' | tr '\n' ' ')
    for i in 1 2 3 4 5; do
        if ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 root@localhost "xbps-install -Sy ${PACKAGES} && echo 'Packages installed successfully!'" 2>/dev/null; then
            break
        fi
        log "Retry $i - waiting for SSH..."
        sleep 10
    done

    log "Shutting down VM..."
    ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost "poweroff" 2>/dev/null || true
    sleep 5
    kill $QEMU_PID 2>/dev/null || true

    log ""
    log "Installation complete! Run: make void-gui"
}

# Run VM with GUI (after installation)
run_vm_gui() {
    log "Starting Void Linux VM (GUI)..."
    log "SSH: ssh -p ${SSH_PORT} user@localhost"
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

# Run VM in CLI mode (after installation)
run_vm() {
    log "Starting Void Linux VM (CLI)..."
    log "SSH: ssh -p ${SSH_PORT} user@localhost"
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
    gui)
        check_deps
        setup_uefi
        [ -f "$DISK_IMAGE" ] || error "No disk image. Run: $0 install"
        run_vm_gui
        ;;
    ssh)
        ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost
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
        echo "Void Linux ${ARCH} VM Manager"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  install   Download ISO and start installer"
        echo "  run       Start the VM (CLI mode)"
        echo "  gui       Start the VM with GUI window"
        echo "  ssh       SSH into the running VM (port ${SSH_PORT})"
        echo "  clean     Remove disk image (keep ISO)"
        echo "  cleanall  Remove all files including ISO"
        echo ""
        echo "Default credentials: root (no password) or anon/voidlinux"
        ;;
esac
