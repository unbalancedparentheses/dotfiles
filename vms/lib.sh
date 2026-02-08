#!/bin/bash
# Shared library for VM setup scripts
# Source this file from individual VM scripts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[*]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

# Check common QEMU dependencies
check_qemu_deps() {
    log "Checking dependencies..."
    command -v qemu-system-aarch64 >/dev/null || error "qemu not found. Run: make switch"
    command -v qemu-img >/dev/null || error "qemu-img not found"
}

# Setup UEFI firmware for aarch64
# Sets UEFI_CODE_SRC variable
setup_uefi() {
    local uefi_vars="${1:-edk2-aarch64-vars.fd}"

    QEMU_PATH=$(which qemu-system-aarch64)
    if [ -z "$QEMU_PATH" ]; then
        error "qemu-system-aarch64 not found"
    fi

    QEMU_REAL=$(readlink -f "$QEMU_PATH")
    QEMU_STORE_PATH=$(echo "$QEMU_REAL" | sed 's|/bin/qemu-system-aarch64||')
    UEFI_CODE_SRC="${QEMU_STORE_PATH}/share/qemu/edk2-aarch64-code.fd"

    if [ ! -f "$UEFI_CODE_SRC" ]; then
        UEFI_CODE_SRC=$(find /nix/store -name "edk2-aarch64-code.fd" -path "*qemu*" 2>/dev/null | head -1)
    fi

    if [ ! -f "$UEFI_CODE_SRC" ]; then
        error "UEFI firmware not found. Run: make switch"
    fi
    log "Using UEFI firmware: $UEFI_CODE_SRC"

    if [ ! -f "$uefi_vars" ]; then
        log "Creating UEFI vars file (64MB)..."
        dd if=/dev/zero of="$uefi_vars" bs=1M count=64 2>/dev/null
    fi
}

# Create disk image
# Args: disk_image, disk_size, uefi_vars (optional)
create_disk() {
    local disk_image="$1"
    local disk_size="$2"
    local uefi_vars="${3:-}"

    if [ -f "$disk_image" ]; then
        local disk_actual_size
        disk_actual_size=$(stat -f%z "$disk_image" 2>/dev/null || stat -c%s "$disk_image" 2>/dev/null)
        if [ "$disk_actual_size" -lt 1000000 ]; then
            warn "Disk image appears incomplete. Recreating..."
            rm -f "$disk_image"
        else
            warn "Disk image already exists: $disk_image"
            read -p "Delete and recreate? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -f "$disk_image"
                [ -n "$uefi_vars" ] && rm -f "$uefi_vars"
            else
                return 1
            fi
        fi
    fi
    log "Creating ${disk_size} disk image..."
    qemu-img create -f qcow2 "$disk_image" "$disk_size"
    [ -n "$uefi_vars" ] && rm -f "$uefi_vars"
}

# Verify ISO size
# Args: iso_file, min_size_bytes
verify_iso_size() {
    local iso_file="$1"
    local min_size="$2"

    if [ -f "$iso_file" ]; then
        local iso_size
        iso_size=$(stat -f%z "$iso_file" 2>/dev/null || stat -c%s "$iso_file" 2>/dev/null)
        if [ "$iso_size" -lt "$min_size" ]; then
            warn "ISO file appears incomplete (${iso_size} bytes). Re-downloading..."
            rm -f "$iso_file"
            return 1
        fi
        return 0
    fi
    return 1
}

# Build common QEMU args for aarch64 VMs
# Args: memory, cpus, uefi_code, uefi_vars, disk_image, ssh_port
build_qemu_base_args() {
    local memory="$1"
    local cpus="$2"
    local uefi_code="$3"
    local uefi_vars="$4"
    local disk_image="$5"
    local ssh_port="$6"

    echo "-machine virt,accel=hvf,highmem=on" \
         "-cpu host" \
         "-m $memory" \
         "-smp $cpus" \
         "-drive if=pflash,format=raw,file=$uefi_code,readonly=on" \
         "-drive if=pflash,format=raw,file=$uefi_vars" \
         "-drive file=$disk_image,if=virtio,format=qcow2" \
         "-device virtio-net-pci,netdev=net0" \
         "-netdev user,id=net0,hostfwd=tcp::${ssh_port}-:22" \
         "-device virtio-balloon"
}

# Wait for SSH to become available
# Args: ssh_port, max_retries, retry_delay, user (default: root)
wait_for_ssh() {
    local ssh_port="$1"
    local max_retries="${2:-10}"
    local retry_delay="${3:-10}"
    local user="${4:-root}"

    log "Waiting for SSH on port ${ssh_port}..."
    for i in $(seq 1 "$max_retries"); do
        if ssh -p "${ssh_port}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
               -o ConnectTimeout=5 "${user}@localhost" "echo ok" >/dev/null 2>&1; then
            log "SSH is ready"
            return 0
        fi
        log "Retry $i/$max_retries - waiting ${retry_delay}s..."
        sleep "$retry_delay"
    done
    error "SSH connection failed after $max_retries attempts"
}

# SSH command helper
# Args: ssh_port, user (default: root)
ssh_cmd() {
    local ssh_port="$1"
    local user="${2:-root}"
    ssh -p "${ssh_port}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${user}@localhost"
}

# Cleanup handler for background processes
# Call: trap 'cleanup_on_exit' EXIT
CLEANUP_PIDS=()

register_cleanup_pid() {
    CLEANUP_PIDS+=("$1")
}

cleanup_on_exit() {
    for pid in "${CLEANUP_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            log "Cleaning up process $pid..."
            kill "$pid" 2>/dev/null || true
        fi
    done
}
