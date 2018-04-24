#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# For use with https://github.com/robherring/generic_device/wiki
#
# Requires
#
#	gcc-aarch64-linux-gnu
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

make_linux_android="$MAKEJ ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-"

configure() {
	cd "$PKG_BUILD_DIR/src"
	if [ -s ".config" ]; then
		mv ".config" ".config.old"
	fi

	# Taken from https://github.com/robherring/generic_device/wiki/Building
	$make_linux_android \
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

	$make_linux_android olddefconfig
}

compile() {
	cd "$PKG_BUILD_DIR/src"

	$make_linux_android
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
	__errmsg "The built image: $PKG_BUILD_DIR/src/arch/arm64/boot/Image"
}
