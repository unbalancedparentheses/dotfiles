#!/bin/bash
# NixOS arm64 VM using QEMU
# For macOS with Apple Silicon

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Source shared library
source "${SCRIPT_DIR}/../lib.sh"

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
UEFI_VARS="edk2-aarch64-vars.fd"

# Check dependencies (NixOS also needs expect)
check_deps() {
    check_qemu_deps
    command -v expect >/dev/null || error "expect not found. Run: make switch"
}

download_iso() {
    if verify_iso_size "$ISO_FILE" 800000000; then
        log "ISO already exists: $ISO_FILE"
        return
    fi
    log "Downloading NixOS ${NIXOS_CHANNEL} ${ARCH} minimal ISO..."
    curl -L -o "$ISO_FILE" "$ISO_URL" || error "Failed to download ISO"
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
    displayManager.startx.enable = true;
  };

  users.users.root.initialPassword = "nixos";

  environment.systemPackages = with pkgs; [
    vim git htop curl wget
    alacritty dmenu i3status feh
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

    trap 'cleanup_on_exit' EXIT

    EXPECT_SCRIPT="/tmp/nixos-autoinstall-$$.exp"
    cat > "$EXPECT_SCRIPT" << 'EXPECTEOF'
#!/usr/bin/expect -f
set timeout 600

log_user 1

spawn {*}[lrange $argv 0 end]

expect {
    "nixos login:" {
        sleep 2
        send "root\r"
    }
    timeout { puts "Timeout waiting for login"; exit 1 }
}

expect {
    "root@nixos" { sleep 1 }
    "#" { sleep 1 }
    timeout { puts "Timeout waiting for shell"; exit 1 }
}

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
        create_disk "$DISK_IMAGE" "$DISK_SIZE" "$UEFI_VARS" || exit 0
        setup_uefi "$UEFI_VARS"
        run_installer
        ;;
    run|start)
        check_deps
        setup_uefi "$UEFI_VARS"
        [ -f "$DISK_IMAGE" ] || error "No disk image. Run: $0 install"
        run_vm
        ;;
    gui)
        check_deps
        setup_uefi "$UEFI_VARS"
        [ -f "$DISK_IMAGE" ] || error "No disk image. Run: $0 install"
        run_vm_gui
        ;;
    ssh)
        ssh_cmd "$SSH_PORT" root
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
