#!/bin/bash

set -e
set -x

test -d ${TARGET_DIR} || mkdir -p ${TARGET_DIR}
test -d ${TMP_DIR} || mkdir -p ${TMP_DIR}

if [ -z "$RELEASE_DATE" ]; then
	RELEASE_DATE=`date +"%Y%m%d.%H%M%S"`
fi

pushd ${TMP_DIR}

test -e rootfs_tmp || mkdir rootfs_tmp

sudo rm -rf rootfs_tmp/*
sudo tar xf $ROOTFS_FILE -C rootfs_tmp

pushd rootfs_tmp

for dir in $ROOTFS_ATTACH_DIRS
do
	sudo cp -rf $dir/* ./
done

sudo cp ${TARGET_DIR}/artik_release etc/

sudo tar zcf ${TARGET_DIR}/rootfs.tar.gz *

popd

sudo rm -rf rootfs_tmp

popd
