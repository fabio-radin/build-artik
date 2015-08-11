#!/bin/bash

set -x

test -e $ROOTFS_FILE || exit 0
test -e $TARGET_DIR/boot.img || exit 0
test -e $TARGET_DIR/sd_boot.img || exit 0
test -e $TARGET_DIR/params.bin || exit 0
test -e $TARGET_DIR/rootfs.tar.gz || exit 0

test -e $TARGET_DIR || mkdir -p $TARGET_DIR

repartition() {
fdisk $1 << __EOF__
n
p
1

+${BOOT_SIZE}M

n
p
2


w
__EOF__
}

IMG_NAME=${TARGET_BOARD}_sdfuse.img

ROOTFS_SIZE=`stat -c%s $ROOTFS_FILE`
ROOTFS_SZ=$((ROOTFS_SIZE >> 20))
TOTAL_SZ=`expr $ROOTFS_SZ + $BOOT_SIZE + $BOOT_SIZE + 2 + 120`

pushd ${TMP_DIR}
dd if=/dev/zero of=$IMG_NAME bs=1M count=$TOTAL_SZ

cp $PREBUILT_DIR/$TARGET_BOARD/bl1.bin $TARGET_DIR/
cp $PREBUILT_DIR/$TARGET_BOARD/tzsw.bin $TARGET_DIR/

dd conv=notrunc if=$TARGET_DIR/sd_boot.img of=$IMG_NAME bs=512

repartition $IMG_NAME

sudo kpartx -a -v ${IMG_NAME}

LOOP_DEV1=`sudo kpartx -l ${IMG_NAME} | awk '{ print $1 }' | awk 'NR == 1'`
LOOP_DEV2=`sudo kpartx -l ${IMG_NAME} | awk '{ print $1 }' | awk 'NR == 2'`

sudo dd conv=notrunc if=$TARGET_DIR/boot.img of=$IMG_NAME bs=1M seek=1048576 count=$BOOT_SIZE oflag=seek_bytes

sudo mkfs.ext4 -F -b 4096 -m 0 -L rootfs /dev/mapper/${LOOP_DEV2}
test -d mnt || mkdir mnt

sudo mount /dev/mapper/${LOOP_DEV2} mnt
sync

sudo cp $TARGET_DIR/bl1.bin mnt
sudo cp $TARGET_DIR/bl2.bin mnt
sudo cp $TARGET_DIR/u-boot.bin mnt
sudo cp $TARGET_DIR/tzsw.bin mnt
sudo cp $TARGET_DIR/params.bin mnt
sudo cp $TARGET_DIR/boot.img mnt
sudo cp $TARGET_DIR/rootfs.tar.gz mnt

sync;sync

sudo umount mnt
sudo kpartx -d ${IMG_NAME}

mv ${IMG_NAME} $TARGET_DIR

popd

ls -al ${TARGET_DIR}/${IMG_NAME}

echo "Done"
