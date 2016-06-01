#!/bin/bash

set -x

TARGET_DIR=
TARGET_BOARD=
TARGET_PACKAGE=
FEDORA_NAME=
PREBUILT_RPM_DIR=
KICKSTART_FILE=../spin-kickstarts/fedora-arm-artik.ks
KICKSTART_DIR=../spin-kickstarts

print_usage()
{
	echo "-h/--help         Show help options"
	echo "-o		Target directory"
	echo "-b		Target board"
	echo "-p		Target package file"
	echo "-n		Output name"
	echo "-r		Prebuilt rpm directory"
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
			-o)
				TARGET_DIR="$2"
				shift ;;
			-b)
				TARGET_BOARD="$2"
				shift ;;
			-p)
				TARGET_PACKAGE="$2"
				shift ;;
			-n)
				FEDORA_NAME="$2"
				shift ;;
			-r)
				PREBUILT_RPM_DIR="$2"
				shift ;;
			-k)
				KICKSTART_FILE="$2"
				shift ;;
			-K)
				KICKSTART_DIR="$2"
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

build_package()
{
	local pkg=$1
	local target_board=$2

	pushd ../$pkg
	fed-artik-build --define "TARGET $target_board"
	popd
}

package_check fed-artik-creator

parse_options "$@"

FEDORA_PACKAGES=`cat $TARGET_PACKAGE`

echo "Clean up local repository..."
fed-artik-build --clean-repos-and-exit

if [ "$PREBUILT_RPM_DIR" != "" ]; then
	fed-artik-creator --copy-rpm-dir $PREBUILT_RPM_DIR
fi

for pkg in $FEDORA_PACKAGES
do
	build_package $pkg $TARGET_BOARD
done

if [ "$FEDORA_NAME" != "" ]; then
	fed-artik-creator --copy-kickstart-dir $KICKSTART_DIR \
		--ks-file $KICKSTART_DIR/$KICKSTART_FILE -o $TARGET_DIR \
		--output-file $FEDORA_NAME
else
	fed-artik-creator --copy-kickstart-dir $KICKSTART_DIR \
		--ks-file $KICKSTART_DIR/$KICKSTART_FILE -o $TARGET_DIR
fi
