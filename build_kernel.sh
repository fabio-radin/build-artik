#!/bin/bash

set -e
set -x

test -d $TARGET_DIR || mkdir -p $TARGET_DIR

cd $KERNEL_DIR
make distclean
make $KERNEL_DEFCONFIG
make zImage -j$JOBS EXTRAVERSION="-$RELEASE_VER"
make $KERNEL_DTB EXTRAVERSION="-$RELEASE_VER"

./scripts/mk_modules.sh $RELEASE_VER

cp arch/arm/boot/zImage $TARGET_DIR
cp arch/arm/boot/dts/$KERNEL_DTB $TARGET_DIR
cp vmlinux $TARGET_DIR
cp usr/modules.img $TARGET_DIR

KERNEL_VERSION=`make ARCH=arm EXTRAVERSION="-$RELEASE_VER" kernelrelease | grep -v scripts`

sed -i "s/RELEASE_KERNEL=/RELEASE_KERNEL=${KERNEL_VERSION}/" ${TARGET_DIR}/artik_release
