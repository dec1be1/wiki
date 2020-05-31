#!/usr/bin/bash

### arch for qemu
QARCH="x86_64"

### enable hardware virtualization with kvm
QKVM="-enable-kvm"

### cpu options
QCPU="-cpu host -smp cores=1,threads=1,sockets=1"

### memory options
QMEM="-m 2048"

### display options
#QDISP="-display gtk"	# pop in a gtk windows
QDISP="-nographic"  # stay in the shell

### serial options
QSERIAL="-serial mon:stdio"	# redirect vm serial port to the terminal (stdio)

### hardrive options
QDRIVE_FILE="./debian.qcow2"
QDRIVE="-drive if=virtio,media=disk,format=qcow2,file=$QDRIVE_FILE"

### boot options
QBOOT="-boot order=c -boot menu=on"     # boot on harddrive
#QBOOT="-cdrom ./debian-10.4.0-amd64-netinst.iso -boot d"	# boot on cdrom (for OS installation)

### network options
QSSH_PORT="9000"
QNET="-device virtio-net,netdev=nic0 -netdev user,id=nic0,hostfwd=tcp::$QSSH_PORT-:22"    # redirect the vm's ssh port to the locélhost's port 9000

### keyboard mapping
QKB="-k fr"

### GO !
$(which qemu-system-$QARCH) $QKVM $QCPU $QMEM $QDISP $QDRIVE $QBOOT $QNET $QKB
