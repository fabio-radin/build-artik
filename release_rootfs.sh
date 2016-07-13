#!/bin/bash

set -e

CHECK_COUNT=0
MAX_RETRY=3
SERVER_URL="http://artik:artik%40iot@59.13.55.140/downloads/artik/fedora"

print_usage()
{
	echo "-h/--help         Show help options"
	echo "-b [TARGET_BOARD]	Target board ex) -b artik710|artik5|artik10"
	echo "-s [SERVER_URL]	Server URL to download the rootfs"

	exit 0
}

parse_options()
{
	for opt in "$@"
	do
		case "$opt" in
			-h|--help)
				print_usage
				shift ;;
			-b)
				TARGET_BOARD="$2"
				shift ;;
			-s)
				SERVER_URL="$2"
				shift ;;
		esac
	done
}

die() {
	if [ -n "$1" ]; then echo $1; fi
	exit 1
}

trap 'error ${LINENO} ${?}' ERR
parse_options "$@"

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
if [ "$TARGET_BOARD" == "" ]; then
	print_usage
else
	if [ "$TARGET_DIR" == "" ]; then
		. $SCRIPT_DIR/config/$TARGET_BOARD.cfg
	fi
fi

test -d ${TARGET_DIR} || mkdir -p ${TARGET_DIR}

if [ ! -f $PREBUILT_DIR/$ROOTFS_FILE ]; then
	echo "Not found rootfs. Just download it"
	wget ${SERVER_URL}/$ROOTFS_FILE -O $PREBUILT_DIR/$ROOTFS_FILE
fi

while :
do
	MD5_SUM=$(md5sum $PREBUILT_DIR/$ROOTFS_FILE | awk '{print $1}')
	if [ "$ROOTFS_FILE_MD5" == "$MD5_SUM" ]; then
		break
	fi

	echo "Mismatch MD5 hash. Just download again"
	wget ${SERVER_URL}/$ROOTFS_FILE -O $PREBUILT_DIR/$ROOTFS_FILE

	CHECK_COUNT=$((CHECK_COUNT + 1))

	if [ $CHECK_COUNT -ge $MAX_RETRY ]; then
		exit -1
	fi
done

cp $PREBUILT_DIR/$ROOTFS_FILE $TARGET_DIR/rootfs.tar.gz
