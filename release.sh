#!/bin/bash

set -x

export RELEASE_DATE=`date +"%Y%m%d.%H%M%S"`
TARGET_DIR_BACKUP=$TARGET_DIR
export TARGET_DIR=$TARGET_DIR/$RELEASE_DATE

sudo ls > /dev/null 2>&1

mkdir -p $TARGET_DIR
cat > $TARGET_DIR/artik_release  << __EOF__
RELEASE_VERSION=${RELEASE_VER}
RELEASE_DATE=${RELEASE_DATE}
__EOF__

./build_uboot.sh
./build_kernel.sh

./mkuInitrd.sh
./mksdboot.sh
./mkbootimg.sh
./release_rootfs.sh

./mksdfuse.sh

ls -al $TARGET_DIR

export TARGET_DIR=$TARGET_DIR_BACKUP
