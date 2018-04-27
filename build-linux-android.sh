#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Requires
#
#	gcc-aarch64-linux-gnu
#	gcc-arm-linux-gnu
#
# For use with https://github.com/robherring/generic_device/wiki
#
# - Daily build of android generic_device, http://snapshots.linaro.org/android/robher-aosp-gendev
#
PKG_NAME=linux-android
PKG_VERSION=4.14.34
PKG_SOURCE="linux-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://cdn.kernel.org/pub/linux/kernel/v${PKG_VERSION%%.*}.x/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=815b808ef64375fec3b2843e4d556c87
PKG_BUILD_DIR_BASENAME="$PKG_NAME-$PKG_VERSION"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PLATFORM=no

. "$PWD/env.sh"
. "$PWD/utils-kconfig.sh"
. "$PWD/utils-linux.sh"

EXTRA_CFLAGS=()
EXTRA_CPPFLAGS=()
EXTRA_LDFLAGS=()
MAKE_VARS=(
	V=1
)

prepare_extra() {
	local f fs

	fs="$(ls "$PKG_SOURCE_DIR")"
	mkdir -p "$PKG_BUILD_DIR/src"
	for f in $fs; do
		mv "$PKG_SOURCE_DIR/$f" "$PKG_BUILD_DIR/src"
	done
}

linux_android_arch=arm
linux_android_arch=arm64
linux_android_make=("${MAKEJ[@]}")
linux_android_make+=("ARCH=$linux_android_arch")
case "$linux_android_arch" in
	arm)
		linux_android_make+=("CROSS_COMPILE=$linux_android_arch-linux-gnu-")
		linux_android_img="$PKG_BUILD_DIR/src/arch/arm/boot/zImage"
		;;
	arm64)
		linux_android_make+=("CROSS_COMPILE=aarch64-linux-gnu-")
		linux_android_img="$PKG_BUILD_DIR/src/arch/arm64/boot/Image"
		;;
	*)
		__errmsg "unknown linux_android_arch: $linux_android_arch"
		false
esac

configure() {
	cd "$PKG_BUILD_DIR/src"
	if [ -s ".config" ]; then
		mv ".config" ".config.old"
	fi

	# Taken from https://github.com/robherring/generic_device/wiki/Building
	"${linux_android_make[@]}" \
		defconfig \
		kvmconfig \
		android-base.config \
		android-recommended.config

	kconfig_set_option CONFIG_ANDROID_LOW_MEMORY_KILLER n

	# For s/w rendering support
	kconfig_set_option CONFIG_DRM y
	kconfig_set_option CONFIG_DRM_BOCHS y
	kconfig_set_option CONFIG_FRAMEBUFFER_CONSOLE y
	kconfig_set_option CONFIG_SW_SYNC y
	kconfig_set_option CONFIG_SYNC_FILE y
	kconfig_set_option CONFIG_VT y

	kconfig_set_option CONFIG_DEFAULT_SECURITY_SELINUX y
	kconfig_set_option CONFIG_DRM_VIRTIO_GPU y
	kconfig_set_option CONFIG_SECCOMP y

	# Needed if we do not have kmod loading support in initrd
	"${linux_android_make[@]}" olddefconfig
	kconfig_set_m_y
	"${linux_android_make[@]}" olddefconfig
	kconfig_set_m_n
}

compile() {
	cd "$PKG_BUILD_DIR/src"

	"${linux_android_make[@]}"
}

staging() {
	true
}

install() {
	true
}

uninstall() {
	true
}

install_post() {
	__errmsg "The built image: $linux_android_img"
}
