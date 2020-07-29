#!/usr/bin/env bash

# Special thanks to...
# https://github.com/Leoyzen/KVM-Opencore
# https://github.com/thenickdude/KVM-Opencore/
# https://github.com/qemu/qemu/blob/master/docs/usb2.txt
#
# See https://www.mail-archive.com/qemu-devel@nongnu.org/msg471657.html
# The "pc-q35-2.4" machine type was changed to "pc-q35-2.9" on 06-August-2017.
# The "media=cdrom" part is needed to make Clover recognize the bootable ISO image.

ALLOCATED_RAM="3072" # MiB
CPU_SOCKETS="1"
CPU_CORES="2"
CPU_THREADS="4"

REPO_PATH="./"
OVMF_DIR="."

qemu-system-x86_64 -enable-kvm -m "$ALLOCATED_RAM" -cpu host,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on \
	-machine pc-q35-2.9 -usb \
	-smp "$CPU_THREADS",cores="$CPU_CORES",sockets="$CPU_SOCKETS" \
	-drive if=pflash,format=raw,readonly,file="$REPO_PATH/$OVMF_DIR/OVMF_CODE.fd" \
	-drive if=pflash,format=raw,file="$REPO_PATH/$OVMF_DIR/OVMF_VARS-1024x768.fd" \
	-drive id=Clover,if=none,snapshot=on,format=qcow2,file=$REPO_PATH/'HighSierra/Clover.qcow2' \
	-drive id=MacHDD,if=none,file=$REPO_PATH/mac_hdd.img,format=qcow2 \
	-drive id=MacDVD,if=none,snapshot=on,media=cdrom,file=$REPO_PATH/'HighSierra-10.13.6.iso' \
	-smbios type=2 \
	-device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" \
	-device usb-kbd -device usb-tablet \
	-device ich9-intel-hda -device hda-duplex \
	-device ide-drive,bus=ide.0,drive=MacDVD \
	-device ide-drive,bus=ide.1,drive=MacHDD \
	-device ide-drive,bus=ide.2,drive=Clover \
	-netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device e1000-82545em,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
	-monitor stdio
