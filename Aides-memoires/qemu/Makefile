#!/usr/bin/make

########## CONFIGURATION ##########

### VM parameters

QARCH		:= x86_64
QEMU		:= $(shell which qemu-system-$(QARCH))
QDRIVE_FILE	:= ./disk.qcow2
QSSH_PORT 	:= 9999
QNAME		:= My_VM

### Qemu options

# general
QEMU_OPTS 	+= -name $(QNAME)
QEMU_OPTS 	+= -enable-kvm -machine q35 -device intel-iommu
QEMU_OPTS 	+= -cpu host -smp cores=1,threads=1,sockets=1
QEMU_OPTS	+= -m 4096
QEMU_OPTS 	+= -device virtio-balloon
QEMU_OPTS 	+= -device virtio-rng-pci
#QEMU_OPTS	+= -bios /usr/share/x64/ovmf/OVMF.fd

# network
QEMU_OPTS 	+= -device virtio-net,netdev=nic0,mac=12:34:56:78:90:ab
QEMU_OPTS 	+= -netdev user,id=nic0,hostfwd=tcp::$(QSSH_PORT)-:22

# drives
QEMU_OPTS	+= -drive if=virtio,media=disk,format=qcow2,discard=unmap,file=$(QDRIVE_FILE)
QEMU_OPTS	+= -boot order=c
#QEMU_OPTS	+= -cdrom ./cdrom.iso
#QEMU_OPTS	+= -snapshot

# misc
QEMU_OPTS	+= -k fr
QEMU_OPTS	+= -device intel-hda -device hda-duplex # soudcard
QEMU_OPTS	+= -rtc base=utc
QEMU_OPTS   += -usb -device usb-tablet

# display (may be done using spice - see next section)
#QEMU_OPTS	+= -nographic
QEMU_OPTS 	+= -vga virtio -display gtk,gl=on

# spice (a specific agent must be installed in the guest)
#QEMU_OPTS	+= -spice port=3001,disable-ticketing
#QEMU_OPTS	+= -device virtio-serial
#QEMU_OPTS	+= -chardev spicevmc,id=vdagent,debug=0,name=vdagent
#QEMU_OPTS	+= -device virtserialport,chardev=vdagent,name=com.redhat.spice.0
#QEMU_OPTS 	+= -vga qxl -display spice-app

# debug
QEMU_OPTS	+= -monitor pty
#QEMU_OPTS	+= -serial pty
#QEMU_OPTS 	+= -serial mon:stdio	# mux the vm console and the qemu monitor
#QEMU_OPTS 	+= -no-shutdown -no-reboot
#QEMU_OPTS 	+= -s -S


########## RULES ##########

start:
	$(QEMU) $(QEMU_OPTS)

