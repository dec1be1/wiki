#!/bin/sh
#
# To find which FS support trim, we check that DISC-MAX (discard max bytes)
# is great than zero. Check discard_max_bytes documentation at
# https://www.kernel.org/doc/Documentation/block/queue-sysfs.txt
#
for fs in $(/bin/lsblk -o MOUNTPOINT,DISC-MAX,FSTYPE | /bin/grep -E '^/.* [1-9]+.* ' | /usr/bin/awk '{print $1}'); do
	/sbin/fstrim "$fs"
done
exit
