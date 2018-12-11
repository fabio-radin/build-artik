# ARTIK Build system
## Contents
1. [Introduction](#1-introduction)
2. [Directory structure](#2-directory-structure)
3. [Build guide](#3-build-guide)
4. [Install guide](#4-install-guide)

## 1. Introduction
This 'build-artik' repository helps to create an ARTIK sd fuse image which can do eMMC recovery from sdcard. Due to long build time of fedora image, the root file system is provided by prebuilt binary and download it from server during build.

---
## 2. Directory structure
- config: Build configurations for artik5 and artik10
	-	common.cfg: common configurations for artik5 and artik10
	-	artik710_ubuntu.cfg: common.cfg + artik710 ubuntu specific configurations
	-	artik710s_ubuntu.cfg: common.cfg + artik710s ubuntu specific configurations
	-	artik530_ubuntu.cfg: common.cfg + artik530 ubuntu specific configurations
	-	artik530s_ubuntu.cfg: common.cfg + artik530s ubuntu specific configurations
	-	artik533s_ubuntu.cfg: common.cfg + artik530s 1G (artik533s) ubuntu specific configurations
-	build_uboot.sh: u-boot build script
-	build_kernel.sh: linux kernel build script
-	build_fedora.sh: fedora build script(Packages + Rootfs tarball)
-	build_ubuntu.sh: ubuntu build script(Packages + Rootfs tarball)
-	mkbootimg.sh: generate /boot partition image which contains kernel, dtb and ramdisk
-	mksdboot.sh: generate a sdcard early boot image(from bl1 to u-boot)
-	mksdfuse.sh: build script for generating sd fusing image from binaries
-	release.sh: build u-boot/kernel and generate sd fusing image

---
## 3. Build guide
### 3.1 Install packages
```
sudo apt-get install kpartx u-boot-tools gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu device-tree-compiler android-tools-fsutils curl
```

### 3.2 Download BSP sources
#### 3.2.1. Download through repo tool
You can download source codes using repo tool. To install the repo tool,
    https://source.android.com/source/downloading.html

- ARTIK710
```
mkdir artik710
cd artik710
repo init -u https://github.com/SamsungARTIK/manifest.git -m artik710_bsp.xml
repo sync
```

- Ubuntu rootfs tarball for artik710 (Download from http://developer.artik.io/downloads/artik710-ubuntu-arm-rootfs-20181030-003001/download)
	- ubuntu-arm-artik710-rootfs-0710GC0F-44U-DJW0-20181030.003001-70d2ac19fcdf90fb0637a60095319022.tar.gz: copy to ../

- ARTIK710S
```
mkdir artik710s
cd artik710s
repo init -u https://github.com/SamsungARTIK/manifest.git -m artik710s_bsp.xml
repo sync
```
- Security Binaries for artik710s (Download from http://developer.artik.io/downloads/artik710s-security-package-20181030-000001/download)
	- fip-secure.img: copy to ../boot-firmwares-artik710s
	- artik710s_codesigner: copy to ../boot-firmwares-artik710s

- Ubuntu rootfs tarball for artik710s (Download from http://developer.artik.io/downloads/artik710s-ubuntu-arm-rootfs-20181030-000001/download)
	- ubuntu-arm-artik710s-rootfs-0710GS0F-44U-DJW0-20181030.000001-166b52e624e342e5d0e255a4dffee147.tar.gz: copy to ../

- ARTIK530
```
mkdir artik530
cd artik530
repo init -u https://github.com/SamsungARTIK/manifest.git -m artik530_bsp.xml
repo sync
```

- Ubuntu rootfs tarball for artik530 (Download from http://developer.artik.io/downloads/artik530-ubuntu-arm-rootfs-20181030-010001/download)
	- ubuntu-arm-artik530-rootfs-0530GC0F-44U-DJW0-20181030.010001-24c0eb3a15abfd050c4b6840dd0c17b0.tar.gz: copy to ../

- ARTIK530S
```
mkdir artik530s
cd artik530s
repo init -u https://github.com/SamsungARTIK/manifest.git -m artik530s_bsp.xml
repo sync
```
- Security Binaries for artik530s (Download from http://developer.artik.io/downloads/artik530s-security-package-20181030-000001/download)
	- secureos.img: copy to ../boot-firmwares-artik530s
	- artik530s_codesigner: copy to ../boot-firmwares-artik530s

- Ubuntu rootfs tarball for artik530s (Download from http://developer.artik.io/downloads/artik530s-ubuntu-arm-rootfs-20181030-000001/download)
	- ubuntu-arm-artik530s-rootfs-0530GS0F-44U-DJW0-20181030.000001-3404a29adecfdfaa832e0b8641760e8f.tar.gz: copy to ../

- ARTIK530s 1G (ARTIK533s)
```
mkdir artik533s
cd artik533s
repo init -u https://github.com/SamsungARTIK/manifest.git -m artik533s_bsp.xml
repo sync
```
- Security Binaries for artik530s 1G (artik533s) (Download from http://developer.artik.io/downloads/artik533s-security-package-20181030-013001/download)
	- secureos.img: copy to ../boot-firmwares-artik533s
	- artik533s_codesigner: copy to ../boot-firmwares-artik533s

- Ubuntu rootfs tarball for artik530s 1G (Download from http://developer.artik.io/downloads/artik533-ubuntu-arm-rootfs-20181030-013001/download)
	- ubuntu-arm-artik533s-rootfs-0533GS0F-44U-DJW0-20181030.013001-bde7ece853389fd5fcd4bd37290d9138.tar.gz: copy to ../

### 3.3 Generate a sd fuse image(for eMMC recovery from sd card)

-	artik710

```
./release.sh -c config/artik710_ubuntu.cfg \
		--local-rootfs ../ubuntu-arm-artik710-rootfs-0710GC0F-44U-DJW0-20181030.003001-70d2ac19fcdf90fb0637a60095319022.tar.gz
```

The output will be 'output/images/artik710/YYYYMMDD.HHMMSS/artik710_sdfuse_UNRELEASED_XXX.img'

-	artik710s

```
./release.sh -c config/artik710s_ubuntu.cfg \
		--local-rootfs ../ubuntu-arm-artik710s-rootfs-0710GS0F-44U-DJW0-20181030.000001-166b52e624e342e5d0e255a4dffee147.tar.gz
```

The output will be 'output/images/artik710s/YYYYMMDD.HHMMSS/artik710s_sdfuse_UNRELEASED_XXX.img'

-	artik530

```
./release.sh -c config/artik530_ubuntu.cfg \
		--local-rootfs ubuntu-arm-artik530-rootfs-0530GC0F-44U-DJW0-20181030.010001-24c0eb3a15abfd050c4b6840dd0c17b0.tar.gz
```

The output will be 'output/images/artik530/YYYYMMDD.HHMMSS/artik530_sdfuse_UNRELEASED_XXX.img'

-	artik530s

```
./release.sh -c config/artik530s_ubuntu.cfg \
		--local-rootfs ubuntu-arm-artik530s-rootfs-0530GS0F-44U-DJW0-20181030.000001-3404a29adecfdfaa832e0b8641760e8f.tar.gz
```

The output will be 'output/images/artik530s/YYYYMMDD.HHMMSS/artik530s_sdfuse_UNRELEASED_XXX.img'

-	artik530s 1G (artik533s)

```
./release.sh -c config/artik533s_ubuntu.cfg \
		--local-rootfs ubuntu-arm-artik533s-rootfs-0533GS0F-44U-DJW0-20181030.013001-bde7ece853389fd5fcd4bd37290d9138.tar.gz
```

The output will be 'output/images/artik533s/YYYYMMDD.HHMMSS/artik533s_sdfuse_UNRELEASED_XXX.img'

### 3.4 Generate a sd bootable image(for SD Card Booting)

-	artik710

```
./release.sh -c config/artik710_ubuntu.cfg -m \
		--local-rootfs ubuntu-arm-artik710-rootfs-0710GC0F-44U-DJW0-20181030.003001-70d2ac19fcdf90fb0637a60095319022.tar.gz
```

-	artik710s

```
./release.sh -c config/artik710s_ubuntu.cfg -m \
		--local-rootfs ubuntu-arm-artik710s-rootfs-0710GS0F-44U-DJW0-20181030.000001-166b52e624e342e5d0e255a4dffee147.tar.gz
```

-	artik530

```
./release.sh -c config/artik530_ubuntu.cfg -m \
		--local-rootfs ubuntu-arm-artik530-rootfs-0530GC0F-44U-DJW0-20181030.010001-24c0eb3a15abfd050c4b6840dd0c17b0.tar.gz
```

-	artik530s

```
./release.sh -c config/artik530s_ubuntu.cfg -m \
		--local-rootfs ubuntu-arm-artik530s-rootfs-0530GS0F-44U-DJW0-20181030.000001-3404a29adecfdfaa832e0b8641760e8f.tar.gz
```

-	artik530s 1G (artik533s)

```
./release.sh -c config/artik533s_ubuntu.cfg -m \
		--local-rootfs ubuntu-arm-artik533s-rootfs-0533GS0F-44U-DJW0-20181030.013001-bde7ece853389fd5fcd4bd37290d9138.tar.gz
```

### 3.5 Install security deb packages which were downloaded from artik.io

-	artik530s
	- copy *.deb files on the target device. (Download from http://developer.artik.io/downloads/artik530s-security-package-20181030-000001/download)

```
dpkg -i libsee-linux-trustware_0.1.6-0_armhf.deb security-b2b-artik530s_0.1.4-0_armhf.deb
```

-	artik530s 1G (artik533s)
	- copy *.deb files on the target device. (Download from http://developer.artik.io/downloads/artik530s-security-package-20181030-000001/download)

```
dpkg -i libsee-linux-trustware_0.1.6-0_armhf.deb security-b2b-artik533s_0.1.0-0_armhf.deb
```

-	artik710s
	- copy *.deb files on the target device. (Download from http://developer.artik.io/downloads/artik710s-security-package-20181030-000001/download)

```
dpkg -i libsee-linux-trustware_0.1.6-0_arm64.deb security-b2b-artik710s_0.1.1-0_arm64.deb
```

---

### 4. Install guide

Please refer https://developer.artik.io/documentation/updating-artik-image.html

---

### 5. Full build guide

This will require long time to make a ubuntu rootfs. You'll require to install sbuild/live buils system. Please refer "Environment set up for ubuntu package build" and "Environment set up for ubuntu rootfs build" from the [ubuntu-build-service](https://github.com/SamsungARTIK/ubuntu-build-service).

#### 5.1. Clone full source tree

- artik710

```
mkdir artik710_full
cd artik710_full
repo init -u https://github.com/SamsungARTIK/manifest.git -m artik710.xml
repo sync
```

- artik710s

```
mkdir artik710s_full
cd artik710s_full
repo init -u https://github.com/SamsungARTIK/manifest.git -m artik710s.xml
repo sync
```

- artik530

```
mkdir artik530_full
cd artik530_full
repo init -u https://github.com/SamsungARTIK/manifest.git -m artik530.xml
repo sync
```

- artik530s

```
mkdir artik530s_full
cd artik530s_full
repo init -u https://github.com/SamsungARTIK/manifest.git -m artik530s.xml
repo sync
```

- artik530s 1G (artik533s)

```
mkdir artik533s_full
cd artik533s_full
repo init -u https://github.com/SamsungARTIK/manifest.git -m artik533s.xml
repo sync
```

#### 5.2. Build with --full-build option

- artik710

```
cd build-artik
./release.sh -c config/artik710_ubuntu.cfg --full-build --ubuntu
```

- artik710s
	- Please download security binaries from http://developer.artik.io/downloads/artik710s-security-package-20181030-000001/download and copy them to following directories.
		- fip-secure.img: copy to ../boot-firmwares-artik710s
		- artik710s_codesigner: copy to ../boot-firmwares-artik710s
		- deb files: copy to ../ubuntu-build-service/prebuilt/arm64/artik710s
```
cd build-artik
./release.sh -c config/artik710s_ubuntu.cfg --full-build --ubuntu
```

- artik530

```
cd build-artik
./release.sh -c config/artik530_ubuntu.cfg --full-build --ubuntu
```

- artik530s
	- Please download security binaries from http://developer.artik.io/downloads/artik530s-security-package-20181030-000001/download and copy them to following directories.
		- secureos.img: copy to ../boot-firmwares-artik530s
		- artik530s_codesigner: copy to ../boot-firmwares-artik530s
		- deb files: copy to ../ubuntu-build-service/prebuilt/armhf/artik530s
```
cd build-artik
./release.sh -c config/artik530s_ubuntu.cfg --full-build --ubuntu
```

- artik530s 1G (artik533s)
	- Please download security binaries from http://developer.artik.io/downloads/artik530s-security-package-20181030-000001/download and copy them to following directories.
		- secureos.img: copy to ../boot-firmwares-artik533s
		- artik533s_codesigner: copy to ../boot-firmwares-artik533s
		- deb files: copy to ../ubuntu-build-service/prebuilt/armhf/artik533s
```
cd build-artik
./release.sh -c config/artik533s_ubuntu.cfg --full-build --ubuntu
```

#### 5.3. Build with --full-build and --skip-ubuntu-build option

To skip building artik ubuntu packages such as bluez, wpa_supplicant, you can use --skip-ubuntu-build option along with --full-build. It will not build and get the packages from artik repository.

- artik710

```
cd build-artik
./release.sh -c config/artik710_ubuntu.cfg --full-build --ubuntu --skip-ubuntu-build
```

- artik710s

```
cd build-artik
./release.sh -c config/artik710s_ubuntu.cfg --full-build --ubuntu --skip-ubuntu-build
```

- artik530

```
cd build-artik
./release.sh -c config/artik530_ubuntu.cfg --full-build --ubuntu --skip-ubuntu-build
```

- artik530s

```
cd build-artik
./release.sh -c config/artik530s_ubuntu.cfg --full-build --ubuntu --skip-ubuntu-build
```

- artik530s 1G (artik533s)

```
cd build-artik
./release.sh -c config/artik533s_ubuntu.cfg --full-build --ubuntu --skip-ubuntu-build
```
