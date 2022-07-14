#!/usr/bin/env bash

PATCH_FILE="${1}"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
	   echo "[!] You must be root to do this. Bye!" 1>&2
	      exit 1
fi

CWD="$(pwd)"

mkdir -p /media/prl_tools
mount -o exec /dev/sr0 /media/prl_tools
cp -r /media/prl_tools /tmp/
umount /media/prl_tools
rmdir /media/prl_tools
cd /tmp/prl_tools/kmods
tar zxvf prl_mod.tar.gz
rm prl_mod.tar.gz
patch --verbose -p1 -i "${PATCH_FILE}"
tar zcvf prl_mod.tar.gz .
cd ..
./install -i --verbose

echo "[+] It's time to reboot now \o/"

cd ${CWD}

exit 0
