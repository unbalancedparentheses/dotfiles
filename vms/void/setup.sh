#!/bin/bash
# Void Linux arm64 VM with GUI (Wayland/Sway) using QEMU
# For macOS with Apple Silicon

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Source shared library
source "${SCRIPT_DIR}/../lib.sh"

# Configuration
ARCH="aarch64"
ISO_BASE_URL="https://repo-default.voidlinux.org/live/current"
ISO_FILE="void-live-${ARCH}.iso"
DISK_IMAGE="void.qcow2"
DISK_SIZE="40G"
MEMORY="4G"
CPUS="4"
SSH_PORT="2223"
UEFI_VARS="edk2-aarch64-vars.fd"

download_iso() {
    if verify_iso_size "$ISO_FILE" 300000000; then
        log "ISO already exists: $ISO_FILE"
        return
    fi
    log "Finding latest Void Linux ${ARCH} ISO..."
    ISO_NAME=$(curl -s "${ISO_BASE_URL}/" | grep -o "void-live-${ARCH}-[0-9]*-base\.iso" | head -1)
    if [ -z "$ISO_NAME" ]; then
        error "Could not find ISO. Check ${ISO_BASE_URL}/"
    fi
    ISO_URL="${ISO_BASE_URL}/${ISO_NAME}"
    log "Downloading: $ISO_NAME"
    curl -L -o "$ISO_FILE" "$ISO_URL" || error "Failed to download ISO"
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

    trap 'cleanup_on_exit' EXIT

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
    register_cleanup_pid $QEMU_PID

    # Verify QEMU started
    sleep 2
    if ! kill -0 $QEMU_PID 2>/dev/null; then
        error "Failed to start QEMU"
    fi

    log "Waiting for VM to boot..."
    sleep 30

    log "Installing packages from packages.txt..."
    if [ ! -f "${SCRIPT_DIR}/packages.txt" ]; then
        warn "packages.txt not found, skipping package installation"
    else
        PACKAGES=$(grep -v '^#' "${SCRIPT_DIR}/packages.txt" | grep -v '^$' | tr '\n' ' ')
        for i in 1 2 3 4 5 6 7 8 9 10; do
            if ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                   -o ConnectTimeout=10 root@localhost \
                   "xbps-install -Sy ${PACKAGES} && echo 'Packages installed successfully!'" 2>/dev/null; then
                break
            fi
            if [ $i -eq 10 ]; then
                warn "Could not install packages via SSH"
                break
            fi
            log "Retry $i/10 - waiting for SSH..."
            sleep 10
        done
    fi

    log "Shutting down VM..."
    ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        root@localhost "poweroff" 2>/dev/null || true
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
        check_qemu_deps
        download_iso
        create_disk "$DISK_IMAGE" "$DISK_SIZE" "$UEFI_VARS" || exit 0
        setup_uefi "$UEFI_VARS"
        run_installer
        ;;
    run|start)
        check_qemu_deps
        setup_uefi "$UEFI_VARS"
        [ -f "$DISK_IMAGE" ] || error "No disk image. Run: $0 install"
        run_vm
        ;;
    gui)
        check_qemu_deps
        setup_uefi "$UEFI_VARS"
        [ -f "$DISK_IMAGE" ] || error "No disk image. Run: $0 install"
        run_vm_gui
        ;;
    ssh)
        ssh_cmd "$SSH_PORT" root
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
