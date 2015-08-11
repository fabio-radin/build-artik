#!/bin/bash

set -e

test -e $PREBUILT_DIR/$INITRD_RAW

test -d $TARGET_DIR || mkdir -p $TARGET_DIR
test -d $TMP_DIR || mkdir -p $TMP_DIR

test -d $TMP_DIR/mnt || mkdir -p $TMP_DIR/mnt

cp $PREBUILT_DIR/$INITRD_RAW $TMP_DIR/
sudo mount -o loop $TMP_DIR/$INITRD_RAW $TMP_DIR/mnt
sudo cp -rf initrd/* $TMP_DIR/mnt/
sync
sudo umount $TMP_DIR/mnt
gzip -c $TMP_DIR/$INITRD_RAW > $TMP_DIR/${INITRD_RAW}.gz
mkimage -A arm -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d $TMP_DIR/${INITRD_RAW}.gz $TARGET_DIR/uInitrd
