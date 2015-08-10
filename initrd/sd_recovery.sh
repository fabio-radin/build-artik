#!/bin/sh

EMMC_DEV=/dev/mmcblk0
EMMC_ROOT_DEV=/dev/mmcblk0p2
EMMC_BOOT_DEV=/dev/mmcblk0p1
SD_ROOT_DEV=/dev/mmcblk1p2

EMMC_BOOT_PART_DEV=/dev/mmcblk0boot0
EMMC_BOOT_PART_SYSFS=/sys/block/mmcblk0boot0

SD_MNT=/root/sd_root
SD_BOOT_MNT=/root/boot

mkdir -p $SD_MNT
mkdir -p $SD_BOOT_MNT

fuse_bootloader()
{
	echo 0 > $EMMC_BOOT_PART_SYSFS/force_ro
	dd if=$SD_MNT/emmc_boot.img of=$EMMC_BOOT_PART_DEV
	sync
	echo 1 > $EMMC_BOOT_PART_SYSFS/force_ro
}

repartition_emmc()
{
	dd if=/dev/zero of=$EMMC_DEV bs=512 count=1
	sync

	ENV_OFFSET=`cat $SD_MNT/env_offset`
	dd if=$SD_MNT/params.bin of=$EMMC_DEV bs=512 seek=$ENV_OFFSET
	sync

	echo -e "n\np\n1\n33\n2080\nn\np\n2\n2081\n\nw" | fdisk ${EMMC_DEV}
	sync; sync; sync
	mdev -s
	sleep 1
}

fuse_boot_partition()
{
	mkfs.vfat $EMMC_BOOT_DEV -n boot
	mount -o loop $SD_MNT/boot.img $SD_BOOT_MNT
	mount $EMMC_BOOT_DEV /mnt
	cp -rf $SD_BOOT_MNT/* /mnt
	sync
	umount /mnt
	umount $SD_BOOT_MNT

	sync; sync
}

fuse_rootfs_partition()
{
	mkfs.ext4 -F $EMMC_ROOT_DEV -L rootfs > /dev/null 2>&1

	mount $EMMC_ROOT_DEV /mnt > /dev/null 2>&1
	pv $SD_MNT/rootfs.tar.gz | tar zxf - -C /mnt > /dev/null 2>&1
	sync; sync; sync
}

mount $SD_ROOT_DEV $SD_MNT

echo "(1/4) Fusing bootloader"
fuse_bootloader > /dev/null 2>&1

echo "(2/4) Repartitioning eMMC"
repartition_emmc > /dev/null 2>&1

echo "(3/4) Fusing boot partition"
fuse_boot_partition > /dev/null 2>&1

echo "(4/4) Fusing rootfs partition"
echo "!!!! Please wait until completion message"
fuse_rootfs_partition

echo "!!!! Complete ARTIK ROOT Filesystem Fusing !!!!"
