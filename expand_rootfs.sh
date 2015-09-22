#!/bin/bash

set -x
set -e

if [ "$#" != "1" ]; then
	echo "Please specify a device node of sdcard"
	echo "ex) sudo ./expand_rootfs.sh /dev/sdc"
	echo "You can see the node from lsblk command"
	exit 0
fi

DEVICE=$1

sudo fdisk $DEVICE <<EOF
p
d
2
n
p
2


p
w
EOF

sync; sync

sudo e2fsck -f ${DEVICE}2
sudo resize2fs ${DEVICE}2

sync; sync

echo "Resize complete"
