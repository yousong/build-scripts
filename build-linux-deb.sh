#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Prerequisites
#
#	apt-get install build-essentials fakeroot
#	apt-get build-dep linux
#
# - Chapter 10 - Debian and the kernel, The Debian GNU/Linux FAQ,
#   https://www.debian.org/doc/manuals/debian-faq/ch-kernel.en.html
# - Debian Linux Kernel Handbook, http://kernel-handbook.alioth.debian.org/
# - 8.10. Compiling a Kernel, The Debian Administrator's Handbook,
#   https://debian-handbook.info/browse/stable/sect.kernel-compilation.html
#
PKG_NAME=linux-deb
PKG_VERSION=4.8.12
PKG_SOURCE="linux-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://cdn.kernel.org/pub/linux/kernel/v${PKG_VERSION%%.*}.x/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=df78d00a183d76eee6b445cb74e6c764
PKG_BUILD_DIR_BASENAME="$PKG_NAME-$PKG_VERSION"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PLATFORM=no

. "$PWD/env.sh"
. "$PWD/utils-kconfig.sh"

EXTRA_CFLAGS=
EXTRA_CPPFLAGS=
EXTRA_LDFLAGS=
MAKE_VARS="V=1"

prepare_extra() {
	local f fs

	fs="$(ls "$PKG_SOURCE_DIR")"
	mkdir -p "$PKG_BUILD_DIR/src"
	for f in $fs; do
		mv "$PKG_SOURCE_DIR/$f" "$PKG_BUILD_DIR/src"
	done
}

configure() {
	local rev
	local dotconfig

	cd "$PKG_BUILD_DIR/src"
	if [ -s ".config" ]; then
		mv ".config" ".config.old"
	fi
	if [ -n "$rev" ]; then
		dotconfig="/boot/config-$rev"
	else
		dotconfig="/boot/config-$(uname -r)"
	fi
	if [ -f "$dotconfig" ]; then
		cp "$dotconfig" .config
	else
		__errmsg "[ -f \"$dotconfig\" ] failed"
		return 1
	fi
	# .version will be incremented by scripts/link-vmlinux.sh and read by scripts/package/builddeb
	rm -f .version
	# disable making dbg deb packages: too big (800+MB)
	kconfig_set_option CONFIG_DEBUG_INFO n
	# types of these options have changed from tristate to bool
	kconfig_set_option CONFIG_CPU_FREQ_STAT y
	kconfig_set_option CONFIG_RXKAD y
	kconfig_set_option CONFIG_SCSI_DH y
	# CONFIG_NF_IP_NAT will enable 'nat' table in iptables and is not available
	# in 3.16 but reappeared in 4.8.
	kconfig_set_option CONFIG_IP_NF_NAT m
	$MAKEJ ARCH=x86_64 olddefconfig
}

compile() {
	cd "$PKG_BUILD_DIR/src"
	DEBFULLNAME="Yousong Zhou" \
	DEBEMAIL="yszhou4tech@gmail.com" \
	   $MAKEJ \
		ARCH=x86_64 \
		LOCALVERSION=-bs \
		KDEB_PKGVERSION=$PKG_VERSION-1 \
		   deb-pkg
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
	local deb

	__errmsg "List of packages"
	for deb in "$PKG_BUILD_DIR/"*.deb; do
		if [ -f "$deb" ]; then
			__errmsg "	sudo dpkg -i $deb"
		fi
	done
}
