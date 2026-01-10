#!/bin/bash
# OpenBSD arm64 VM automation script using QEMU
# Supports fully automated installation via autoinstall
# For GUI alternative, use UTM - see README.md

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration
OPENBSD_VERSION="7.8"
ARCH="arm64"
ISO_URL="https://cdn.openbsd.org/pub/OpenBSD/${OPENBSD_VERSION}/${ARCH}/install78.iso"
ISO_FILE="install78.iso"
DISK_IMAGE="openbsd.qcow2"
DISK_SIZE="20G"
MEMORY="2G"
CPUS="2"
SSH_PORT="2222"
HTTP_PORT="8080"

# UEFI firmware (required for arm64)
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

# Check dependencies
check_deps() {
    log "Checking dependencies..."
    command -v qemu-system-aarch64 >/dev/null || error "qemu not found. Run: make switch (from parent directory)"
    command -v qemu-img >/dev/null || error "qemu-img not found"
    command -v python3 >/dev/null || error "python3 not found"
    command -v expect >/dev/null || error "expect not found. Run: make switch (from parent directory)"
}

# Download OpenBSD ISO
download_iso() {
    if [ -f "$ISO_FILE" ]; then
        # Check if ISO is valid (should be > 500MB)
        ISO_SIZE=$(stat -f%z "$ISO_FILE" 2>/dev/null || stat -c%s "$ISO_FILE" 2>/dev/null)
        if [ "$ISO_SIZE" -lt 500000000 ]; then
            warn "ISO file appears incomplete (${ISO_SIZE} bytes). Re-downloading..."
            rm -f "$ISO_FILE"
        else
            log "ISO already exists: $ISO_FILE"
            return
        fi
    fi
    log "Downloading OpenBSD ${OPENBSD_VERSION} ${ARCH} ISO..."
    curl -L -o "$ISO_FILE" "$ISO_URL"
}

# Setup UEFI firmware
setup_uefi() {
    # Find UEFI firmware from qemu package in nix store
    QEMU_PATH=$(which qemu-system-aarch64)
    if [ -z "$QEMU_PATH" ]; then
        error "qemu-system-aarch64 not found"
    fi

    # Resolve symlinks to find actual nix store path
    QEMU_REAL=$(readlink -f "$QEMU_PATH")
    QEMU_STORE_PATH=$(echo "$QEMU_REAL" | sed 's|/bin/qemu-system-aarch64||')
    UEFI_CODE_SRC="${QEMU_STORE_PATH}/share/qemu/edk2-aarch64-code.fd"

    if [ ! -f "$UEFI_CODE_SRC" ]; then
        # Fallback: search in nix store
        UEFI_CODE_SRC=$(find /nix/store -name "edk2-aarch64-code.fd" -path "*qemu*" 2>/dev/null | head -1)
    fi

    if [ ! -f "$UEFI_CODE_SRC" ]; then
        error "UEFI firmware not found. Ensure qemu is installed: make switch"
    fi
    log "Using UEFI firmware: $UEFI_CODE_SRC"

    # Create UEFI vars file if it doesn't exist (must be 64MB)
    if [ ! -f "$UEFI_VARS" ]; then
        log "Creating UEFI vars file (64MB)..."
        dd if=/dev/zero of="$UEFI_VARS" bs=1M count=64 2>/dev/null
    fi
}

# Create disk image
create_disk() {
    if [ -f "$DISK_IMAGE" ]; then
        # Check if disk is valid (should be > 1MB for a real qcow2)
        DISK_ACTUAL_SIZE=$(stat -f%z "$DISK_IMAGE" 2>/dev/null || stat -c%s "$DISK_IMAGE" 2>/dev/null)
        if [ "$DISK_ACTUAL_SIZE" -lt 1000000 ]; then
            warn "Disk image appears incomplete. Recreating..."
            rm -f "$DISK_IMAGE"
        else
            warn "Disk image already exists: $DISK_IMAGE"
            read -p "Delete and recreate? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -f "$DISK_IMAGE" "$UEFI_VARS"
            else
                return 1
            fi
        fi
    fi
    log "Creating ${DISK_SIZE} disk image..."
    qemu-img create -f qcow2 "$DISK_IMAGE" "$DISK_SIZE"
    # Reset UEFI vars for fresh install
    rm -f "$UEFI_VARS"
}

# Start HTTP server for autoinstall
start_http_server() {
    log "Starting HTTP server on port ${HTTP_PORT} for autoinstall..."
    # Kill any existing server on this port
    pkill -f "python3 -m http.server ${HTTP_PORT}" 2>/dev/null || true
    sleep 1
    # Start server in background
    python3 -m http.server ${HTTP_PORT} --directory "$SCRIPT_DIR" > /dev/null 2>&1 &
    HTTP_PID=$!
    echo $HTTP_PID > .http_server.pid
    sleep 1
    # Verify it started
    if ! kill -0 $HTTP_PID 2>/dev/null; then
        error "Failed to start HTTP server"
    fi
    log "HTTP server started (PID: $HTTP_PID)"
}

# Stop HTTP server
stop_http_server() {
    if [ -f .http_server.pid ]; then
        HTTP_PID=$(cat .http_server.pid)
        kill $HTTP_PID 2>/dev/null || true
        rm -f .http_server.pid
    fi
    pkill -f "python3 -m http.server ${HTTP_PORT}" 2>/dev/null || true
}

# Run fully automated installation using expect
run_autoinstall() {
    log "Starting fully automated OpenBSD installation..."
    log ""
    log "This will run unattended. The VM will:"
    log "  1. Boot from ISO"
    log "  2. Auto-select install mode"
    log "  3. Fetch install.conf from local HTTP server"
    log "  4. Install OpenBSD automatically"
    log "  5. Halt when complete"
    log ""
    log "Installation takes ~10-15 minutes. Progress shown below."
    log ""

    # Start HTTP server for install.conf
    start_http_server
    trap stop_http_server EXIT

    # Create expect script for automation
    EXPECT_SCRIPT="/tmp/openbsd-autoinstall-$$.exp"
    cat > "$EXPECT_SCRIPT" << 'EXPECT_EOF'
#!/usr/bin/expect -f
set timeout 300
set http_port [lindex $argv 0]

log_user 1

# Spawn QEMU
spawn {*}[lrange $argv 1 end]

# Wait for install menu
expect {
    "boot>" {
        send "\r"
        exp_continue
    }
    "hell?" {
        sleep 1
        send "a\r"
    }
    timeout { puts "Timeout waiting for install menu"; exit 1 }
}

# Provide URL for install.conf
expect {
    "ocation?" {
        send "http://10.0.2.2:${http_port}/install.conf\r"
    }
    timeout { puts "Timeout waiting for response file prompt"; exit 1 }
}

# Let the installation proceed - wait for CONGRATULATIONS or halt
set timeout 3600
expect {
    "CONGRATULATIONS" {
        puts "\n\nInstallation successful! Waiting for halt..."
        expect {
            "halt" { }
            "reboot" { }
            eof { }
            timeout { }
        }
    }
    "The following command" {
        # This appears right before CONGRATULATIONS
        exp_continue
    }
    "syncing disks" {
        puts "\n\nSystem halting..."
    }
    eof { }
    timeout { puts "Installation timed out after 1 hour"; exit 1 }
}

puts "\n\nInstallation completed!"
EXPECT_EOF

    chmod +x "$EXPECT_SCRIPT"

    # Run expect with QEMU command
    expect "$EXPECT_SCRIPT" "$HTTP_PORT" \
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

    # Cleanup
    rm -f "$EXPECT_SCRIPT"
    stop_http_server

    log ""
    log "Installation complete!"
    log "Run 'make openbsd-run' to start the VM"
}

# Run QEMU normally (after installation)
run_vm() {
    log "Starting OpenBSD VM..."
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

# Main
case "${1:-}" in
    install)
        check_deps
        download_iso
        create_disk || exit 0
        setup_uefi
        run_autoinstall
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
    clean)
        log "Cleaning up VM files..."
        stop_http_server
        rm -f "$DISK_IMAGE" "$UEFI_VARS" .http_server.pid
        log "Done. ISO preserved."
        ;;
    cleanall)
        log "Removing all files..."
        stop_http_server
        rm -f "$DISK_IMAGE" "$UEFI_VARS" "$ISO_FILE" .http_server.pid
        log "Done."
        ;;
    *)
        echo "OpenBSD ${OPENBSD_VERSION} ${ARCH} VM Manager"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  install   Fully automated installation (unattended)"
        echo "  run       Start the VM (after installation)"
        echo "  ssh       SSH into the running VM"
        echo "  clean     Remove disk image and UEFI vars (keep ISO)"
        echo "  cleanall  Remove all files including ISO"
        echo ""
        echo "Default credentials: root:openbsd  user:openbsd"
        ;;
esac
