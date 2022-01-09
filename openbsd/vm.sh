#!/bin/sh

ISO=install70.iso
URL=https://cdn.openbsd.org/pub/OpenBSD/7.0/amd64/$ISO

if [ ! -f ./$ISO ]; then
	wget $URL > $ISO
fi

if [ ! -f ./openbsd.img ]; then
	qemu-img create openbsd.img 10G
	qemu-system-x86_64 -boot d -cdrom ./$ISO -m 2048 -hda openbsd.img -enable-kvm -curses
fi

qemu-system-x86_64 -m 2048 -nic user -hda openbsd.img -enable-kvm -curses 
