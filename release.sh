#!/bin/bash

print_usage()
{
	echo "-h/--help         Show help options"
	echo "-c/--config       Config file path to build ex) -c config/artik5.cfg"
	echo "-t/--customer     customer code to release GC:general ST:SmartThings"
	echo "                  ex) -t GC"
	echo "-n/--connectivity Connectivity code, bit 0: Ehternet, bit 1: Wifi"
	echo "                  bit 2: BT, bit 3: ZigBee, bit 4: ZWave, bit 5: LPWA"
	echo "                  ex) -n 0E #(Wifi/BT/ZigBee), -n 0F #(Ethernet/Wifi/BT/ZigBee)"
	echo "-w                Linux version, 3.10 -> 3A, ex) -w 3A"
	echo "-f/--rootfs       Rootfs type, Y: Yocto, F: Fedora, U : Ubuntu, T : Tizen, A : Android"
	echo "                  ex) -f F # Rootfs is Fedora"
	echo "-p/--patchver     SW Patch version - 00 ~ zz, ex) -p 01"
	echo "-q/--swqual       SW Qual status, FS:0, ES:E, CS:Q, Test:T"
	echo "-r/--rcver        SW RC version, 0~z"
	echo "-v/--fullver      Pass full version name like: -v A50GC0E-3AF-01030"
	echo "-d/--date		Release date: -d 20150911.112204"
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
			-c|--config)
				CONFIG_FILE="$2"
				shift ;;
			-t|--customer)
				CUSTOMER_CODE="$2"
				shift ;;
			-n|--connectivity)
				CONNECTIVITY_CODE="$2"
				shift ;;
			-f|--rootfs)
				ROOTFS_TYPE="$2"
				shift ;;
			-w|--swver)
				SW_VERSION="$2"
				shift ;;
			-p|--patchver)
				PATCH_VERSION="$2"
				shift ;;
			-q|--swqual)
				SW_QUAL="$2"
				shift ;;
			-r|--rcver)
				RC_VER="$2"
				shift ;;
			-v|--fullver)
				REL_VER="$2"
				shift ;;
			-d|--date)
				RELEASE_DATE="$2"
				shift ;;
			*)
				shift ;;
		esac
	done
}

make_release_version()
{
	if [ "$CUSTOMER_CODE" != "" ]; then
		RELEASE_VER=${RELEASE_VER:0:3}${CUSTOMER_CODE}${RELEASE_VER:5}
	fi
	if [ "$CONNECTIVITY_CODE" != "" ]; then
		RELEASE_VER=${RELEASE_VER:0:5}${CONNECTIVITY_CODE}${RELEASE_VER:7}
	fi
	if [ "$SW_VERSION" != "" ]; then
		RELEASE_VER=${RELEASE_VER:0:8}${SW_VERSION}${RELEASE_VER:10}
	fi
	if [ "$ROOTFS_TYPE" != "" ]; then
		RELEASE_VER=${RELEASE_VER:0:10}${ROOTFS_TYPE}${RELEASE_VER:11}
	fi
	if [ "$PATCH_VERSION" != "" ]; then
		RELEASE_VER=${RELEASE_VER:0:12}${PATCH_VERSION}${RELEASE_VER:14}
	fi
	if [ "$SW_QUAL" != "" ]; then
		RELEASE_VER=${RELEASE_VER:0:14}${SW_QUAL}${RELEASE_VER:15}
	fi
	if [ "$RC_VER" != "" ]; then
		RELEASE_VER=${RELEASE_VER:0:15}${RC_VER}${RELEASE_VER:16}
	fi
	if [ "$REL_VER" != "" ]; then
		RELEASE_VER=$REL_VER
	fi
	export RELEASE_VER=$RELEASE_VER
}

parse_options "$@"

if [ "$CONFIG_FILE" != "" ]
then
	. $CONFIG_FILE
fi

make_release_version

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

./mkuInitrd.sh
./mksdboot.sh
./mkbootimg.sh
./release_rootfs.sh

./mksdfuse.sh

ls -al $TARGET_DIR

echo "ARTIK release information"
cat $TARGET_DIR/artik_release

export TARGET_DIR=$TARGET_DIR_BACKUP
