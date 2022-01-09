#!/bin/sh
wget https://cdn.openbsd.org/pub/OpenBSD/7.0/amd64/install70.iso
qemu-img create openbsd.img 10G
qemu-system-x86_64 -boot d -cdrom ./install70.iso -m 2048 -hda openbsd.img -enable-kvm -curses
