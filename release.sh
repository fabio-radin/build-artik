#!/bin/bash

set -e

FULL_BUILD=false

print_usage()
{
	echo "-h/--help         Show help options"
	echo "-c/--config       Config file path to build ex) -c config/artik5.cfg"
	echo "-v/--fullver      Pass full version name like: -v A50GC0E-3AF-01030"
	echo "-d/--date		Release date: -d 20150911.112204"
	echo "-m/--microsd	Make a microsd bootable image"
	echo "-u/--url		Specify an url for downloading rootfs"
	exit 0
}

error()
{
	JOB="$0"              # job name
	LASTLINE="$1"         # line of error occurrence
	LASTERR="$2"          # error code
	echo "ERROR in ${JOB} : line ${LASTLINE} with exit code ${LASTERR}"
	exit 1
}

parse_options()
{
	for opt in "$@"
	do
		case "$opt" in
			-h|--help)
				print_usage
				shift ;;
			-c|--config)
				CONFIG_FILE="$2"
				shift ;;
			-v|--fullver)
				RELEASE_VER="$2"
				shift ;;
			-d|--date)
				RELEASE_DATE="$2"
				shift ;;
			-m|--microsd)
				MICROSD_IMAGE="1"
				shift ;;
			-u|--url)
				SERVER_URL="$2"
				shift ;;
			--full-build)
				FULL_BUILD=true
				shift ;;
			*)
				shift ;;
		esac
	done
}

package_check()
{
	command -v $1 >/dev/null 2>&1 || { echo >&2 "${1} not installed. Aborting."; exit 1; }
}

trap 'error ${LINENO} ${?}' ERR
parse_options "$@"

package_check kpartx
package_check mkimage
package_check arm-linux-gnueabihf-gcc

if [ "$CONFIG_FILE" != "" ]
then
	. $CONFIG_FILE
fi

if [ "$RELEASE_DATE" == "" ]
then
	RELEASE_DATE=`date +"%Y%m%d.%H%M%S"`
fi

export RELEASE_DATE=$RELEASE_DATE
TARGET_DIR_BACKUP=$TARGET_DIR

export TARGET_DIR=$TARGET_DIR/$RELEASE_VER/$RELEASE_DATE

sudo ls > /dev/null 2>&1

mkdir -p $TARGET_DIR
cat > $TARGET_DIR/artik_release  << __EOF__
RELEASE_VERSION=${RELEASE_VER}
RELEASE_DATE=${RELEASE_DATE}
__EOF__

./build_uboot.sh
./build_kernel.sh

./mksdboot.sh $MICROSD_IMAGE
./mkbootimg.sh

if $FULL_BUILD ; then
	./build_fedora.sh $TARGET_DIR $TARGET_BOARD
	FEDORA_TARBALL=`find $TARGET_DIR -name "fedora-arm-artik-rootfs*"`
	cp $FEDORA_TARBALL $TARGET_DIR/rootfs.tar.gz
else
	./release_rootfs.sh $SERVER_URL
fi

./mksdfuse.sh $MICROSD_IMAGE

./mkrootfs_image.sh $TARGET_DIR

cp flash_all_by_fastboot.sh $TARGET_DIR
cp prebuilt/$TARGET_BOARD/u-boot-recovery.bin $TARGET_DIR

ls -al $TARGET_DIR

echo "ARTIK release information"
cat $TARGET_DIR/artik_release

export TARGET_DIR=$TARGET_DIR_BACKUP
