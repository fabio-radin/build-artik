#!/bin/sh

EMMC_ROOT_DEV=/dev/mmcblk0p2
SD_ROOT_DEV=/dev/mmcblk1p2

SD_MNT=/root/sd_root

mkdir -p $SD_MNT

fuse_rootfs_partition()
{
	mkfs.ext4 -F $EMMC_ROOT_DEV -L rootfs > /dev/null 2>&1

	mount -t ext4 $EMMC_ROOT_DEV /mnt > /dev/null 2>&1
	pv $SD_MNT/rootfs.tar.gz | tar zxf - -C /mnt > /dev/null 2>&1
	sync; sync; sync
}

mount -t ext4 $SD_ROOT_DEV $SD_MNT

echo "(1/1) Fusing rootfs partition"
echo "Please wait until completion message"
fuse_rootfs_partition

echo "!!!! Complete ARTIK ROOT Filesystem Fusing !!!!"
