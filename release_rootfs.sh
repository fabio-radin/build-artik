#!/bin/bash

set -x

test -d ${TARGET_DIR} || mkdir -p ${TARGET_DIR}

if [ ! -f $PREBUILT_DIR/$ROOTFS_FILE ]; then
	echo "Not found rootfs. Just download it"
	wget http://artik:artik%40iot@59.13.55.140/downloads/artik/fedora/$ROOTFS_FILE -O $PREBUILT_DIR/$ROOTFS_FILE
fi

cp $PREBUILT_DIR/$ROOTFS_FILE $TARGET_DIR/rootfs.tar.gz
