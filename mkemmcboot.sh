#!/bin/bash

set -x
set -e

EMMC_BOOT_SZ=`expr $EMMC_ENV_OFFSET + 32`

test -e $PREBUILT_DIR/$TARGET_BOARD/bl1.bin || exit 0
test -e $PREBUILT_DIR/$TARGET_BOARD/tzsw.bin || exit 0
test -e $TARGET_DIR/bl2.bin || exit 0
test -e $TARGET_DIR/u-boot.bin || exit 0
test -e $TARGET_DIR/params.bin || exit 0

IMG_NAME=emmc_boot.img

test -d ${TARGET_DIR} || mkdir -p ${TARGET_DIR}
test -d ${TMP_DIR} || mkdir -p ${TMP_DIR}

pushd ${TMP_DIR}

cp $PREBUILT_DIR/$TARGET_BOARD/bl1.bin $TARGET_DIR/
cp $PREBUILT_DIR/$TARGET_BOARD/tzsw.bin $TARGET_DIR/

dd if=/dev/zero of=$IMG_NAME bs=512 count=$EMMC_BOOT_SZ

dd conv=notrunc if=$TARGET_DIR/bl1.bin of=$IMG_NAME bs=512 seek=$EMMC_BL1_OFFSET
dd conv=notrunc if=$TARGET_DIR/bl2.bin of=$IMG_NAME bs=512 seek=$EMMC_BL2_OFFSET
dd conv=notrunc if=$TARGET_DIR/u-boot.bin of=$IMG_NAME bs=512 seek=$EMMC_UBOOT_OFFSET
dd conv=notrunc if=$TARGET_DIR/tzsw.bin of=$IMG_NAME bs=512 seek=$EMMC_TZSW_OFFSET
dd conv=notrunc if=$TARGET_DIR/params.bin of=$IMG_NAME bs=512 seek=$EMMC_ENV_OFFSET

sync

mv $IMG_NAME $TARGET_DIR

popd
