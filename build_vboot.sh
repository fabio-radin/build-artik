#!/bin/bash

set -e

print_usage() {
	cat <<EOF
	usage: ${0##*/}

	-h              Print this help message
	-b [TARGET_BOARD]	Target board ex) -b artik5 | artik520s
	--vboot-keydir	Specify key directoy for verified boot
	--vboot-its	Specify its file for verified boot
EOF
	exit 0
}

parse_options()
{
	for opt in "$@"
	do
		case "$opt" in
			-h|--help)
				usage
				shift ;;
			-b)
				TARGET_BOARD="$2"
				shift ;;
			--vboot-keydir)
				VBOOT_KEYDIR="$2"
				shift ;;
			--vboot-its)
				VBOOT_ITS="$2"
				shift ;;
			*)
				shift ;;
		esac
	done
}

trap 'error ${LINENO} ${?}' ERR
parse_options "$@"

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`

if [ "$TARGET_BOARD" == "" ]; then
	print_usage
else
	if [ "$UBOOT_DIR" == "" ]; then
		. $SCRIPT_DIR/config/$TARGET_BOARD.cfg
	fi
fi

if [ "$VBOOT_KEYDIR" == "" ]; then
	echo "Please specify key directory using --vboot-keydir"
	exit 0
fi

./build_uboot.sh
./build_kernel.sh

if [ "$VBOOT_ITS" == "" ]; then
	VBOOT_ITS=$PREBUILT_DIR/kernel_fit_verify.its
fi

./mkvboot.sh $TARGET_DIR $VBOOT_KEYDIR $VBOOT_ITS

ls -1 $TARGET_DIR
