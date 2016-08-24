#!/bin/bash

set -e

CHECK_COUNT=0
MAX_RETRY=3
SERVER_URL="http://artik:artik%40iot@agit.artik.io:8080/downloads/artik/fedora/"
DOWNLOAD_DONE=false

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
			-f)
				ROOTFS_FILE="$2"
				shift ;;
			*)
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

download_rootfs_file()
{
	if [ "$BUILD_VERSION" != "UNRELEASED" ] ; then
		ROOTFS_PREFIX=fedora-arm-$TARGET_BOARD-rootfs-$BUILD_VERSION-$BUILD_DATE
	else
		ROOTFS_PREFIX=fedora-arm-$TARGET_BOARD-rootfs-latest
	fi

	pushd prebuilt
	ROOTFS_NAME=`curl -s ${SERVER_URL} --list-only | \
		sed -n 's%.*href="\([^.]*\.tar\.gz\)".*%\n\1%; ta; b; :a; s%.*\n%%; p' | grep "${ROOTFS_PREFIX}"` || true

	if [ "$ROOTFS_NAME" == "" ]; then
		ROOTFS_PREFIX=fedora-arm-$TARGET_BOARD-rootfs-latest
		ROOTFS_NAME=`curl -s ${SERVER_URL} --list-only | \
			sed -n 's%.*href="\([^.]*\.tar\.gz\)".*%\n\1%; ta; b; :a; s%.*\n%%; p' | grep "${ROOTFS_PREFIX}"` || true
	fi

	wget -nc ${SERVER_URL}${ROOTFS_NAME}

	ROOTFS_MD5_PRE="${ROOTFS_NAME#$ROOTFS_PREFIX-*}"
	ROOTFS_MD5="${ROOTFS_MD5_PRE%%.tar.gz}"

	MD5_SUM=$(md5sum $ROOTFS_NAME | awk '{print $1}')
	if [ "$ROOTFS_MD5" == "$MD5_SUM" ]; then
		DOWNLOAD_DONE=true
	fi
	popd
}

while :
do
	download_rootfs_file
	if $DOWNLOAD_DONE; then
		break
	fi

	echo "Mismatch MD5 hash. Just download again"

	CHECK_COUNT=$((CHECK_COUNT + 1))

	if [ $CHECK_COUNT -ge $MAX_RETRY ]; then
		exit -1
	fi
done

cp prebuilt/$ROOTFS_NAME $TARGET_DIR/rootfs.tar.gz
