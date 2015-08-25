#!/bin/bash

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

# Fix rootfs failed service
sudo sed -i 's/kernel.pid_max = 65536/kernel.pid_max = 32768/g' etc/sysctl.conf

sudo mkdir var/log/sa

# Remove unnecessary services
sudo rm etc/systemd/system/multi-user.target.wants/cups.path
sudo rm etc/systemd/system/sockets.target.wants/cups.socket
sudo rm etc/systemd/system/multi-user.target.wants/sendmail.service
sudo rm etc/systemd/system/multi-user.target.wants/sm-client.service

# Remove invalid openstack repo
sudo rm etc/yum.repos.d/rdo-release.repo

# Use mirror repo for updates
sudo sed -i "s/baseurl=/#baseurl=/g" etc/yum.repos.d/fedora.repo
sudo sed -i "s/#metalink=/metalink=/g" etc/yum.repos.d/fedora.repo

sudo sed -i "s/baseurl=/#baseurl=/g" etc/yum.repos.d/fedora-updates.repo
sudo sed -i "s/#metalink=/metalink=/g" etc/yum.repos.d/fedora-updates.repo

# Allow to access ssh for other users
sudo sed -i "/AllowUsers /d" etc/ssh/sshd_config

sudo cp ${TARGET_DIR}/artik_release etc/

sudo tar zcf ${TARGET_DIR}/rootfs.tar.gz *

popd

sudo rm -rf rootfs_tmp

popd
