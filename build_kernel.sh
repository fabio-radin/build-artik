#!/bin/bash

set -e
set -x

test -d $TARGET_DIR || mkdir -p $TARGET_DIR

cd $KERNEL_DIR
make distclean
make $KERNEL_DEFCONFIG
make zImage -j$JOBS
make $KERNEL_DTB

cp arch/arm/boot/zImage $TARGET_DIR
cp arch/arm/boot/dts/$KERNEL_DTB $TARGET_DIR

KERNEL_VERSION=`make ARCH=arm kernelrelease`

echo "RELEASE_KERNEL=${KERNEL_VERSION}" >> $TARGET_DIR/artik_release
