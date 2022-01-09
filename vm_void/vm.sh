#!/bin/sh

ISO=void-live-x86_64-20210930.iso
URL=https://alpha.de.repo.voidlinux.org/live/current/$ISO

if [ ! -f ./$ISO ]; then
	wget $URL > $ISO
fi

if [ ! -f ./void.img ]; then
	qemu-img create void.img 10G
	qemu-system-x86_64 -boot d -cdrom ./$ISO -m 2048 -hda void.img -enable-kvm
fi

qemu-system-x86_64 -m 2048 -nic user -hda void.img -enable-kvm -curses --nographic 
