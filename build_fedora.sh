#!/bin/bash

set -x

TARGET_DIR=$1
TARGET_BOARD=$2
FEDORA_NAME=$3

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

FEDORA_PACKAGES=`cat config/artik5_fedora.package`

echo "Clean up local repository..."
fed-artik-build --clean-repos-and-exit

for pkg in $FEDORA_PACKAGES
do
	build_package $pkg $TARGET_BOARD
done

if [ "$FEDORA_NAME" != "" ]; then
	fed-artik-creator --copy-kickstart-dir ../spin-kickstarts \
		--ks-file ../spin-kickstarts/fedora-arm-artik.ks -o $TARGET_DIR \
		--output-file $FEDORA_NAME
else
	fed-artik-creator --copy-kickstart-dir ../spin-kickstarts \
		--ks-file ../spin-kickstarts/fedora-arm-artik.ks -o $TARGET_DIR
fi
