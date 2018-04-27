#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Prerequisites
#
#	yum groupinstall "Development Tools"
#	yum install ncurses-devel
#	yum install hmaccalc zlib-devel binutils-devel elfutils-libelf-devel
#
PKG_NAME=linux-rpm
PKG_VERSION=4.14.37
PKG_SOURCE="linux-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://cdn.kernel.org/pub/linux/kernel/v${PKG_VERSION%%.*}.x/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=82b7a828b228dd7a581dc3fc1174ea15
PKG_BUILD_DIR_BASENAME="$PKG_NAME-$PKG_VERSION"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PLATFORM=no

. "$PWD/env.sh"
. "$PWD/utils-kconfig.sh"

EXTRA_CFLAGS=()
EXTRA_CPPFLAGS=()
EXTRA_LDFLAGS=()
MAKE_VARS=(
	V=1
)
STRIP=()

prepare_extra() {
	local f fs

	fs="$(ls "$PKG_SOURCE_DIR")"
	mkdir -p "$PKG_BUILD_DIR/src"
	for f in $fs; do
		mv "$PKG_SOURCE_DIR/$f" "$PKG_BUILD_DIR/src"
	done
}

configure() {
	local opt

	cd "$PKG_BUILD_DIR/src"
	if [ -s ".config" ]; then
		mv ".config" ".config.old"
	fi
	if [ -f "/boot/config-$(uname -r)" ]; then
		cp "/boot/config-$(uname -r)" .config
	fi
	# .version will be incremented by scripts/link-vmlinux.sh and read by scripts/package/builddeb
	rm -f .version
	# disable making dbg deb packages: too big (800+MB)
	kconfig_set_option CONFIG_DEBUG_INFO n
	# types of these options have changed from tristate to bool
	for opt in \
			MICROCODE \
			CPU_FREQ_STAT \
			X86_INTEL_PSTATE \
			PCCARD_NONSTATIC \
			MFD_WM8400 \
			MFD_WM831X \
			MFD_WM8350 \
			MFD_WM8350_I2C \
			AB3100_CORE \
			; do
		kconfig_set_option "CONFIG_$opt" y
	done
	# CONFIG_NF_IP_NAT will enable 'nat' table in iptables and is not available
	# in 3.16 but reappeared in 4.8.
	kconfig_set_option CONFIG_IP_NF_NAT m
	$MAKEJ ARCH=x86_64 olddefconfig
}

compile() {
	local rpmopts=()
	local topdir="$PKG_BUILD_DIR/rpmbuild"

	mkdir -p "$topdir"
	rpmopts+=(--define "'_topdir $topdir'")

	# scripts/package/mkspec provides packages kernel, kernel-devel,
	# kernel-headers.  No --with debug, --with debuginfo provided as compared
	# to the ones from rhel kernel.spec file
	#
	#  - kernel, the kernel
	#  - kernel-headers, user api headers for use with glibc etc.
	#  - kernel-devel, files for building kernel modules
	#
	# There are two Makefile target for rpms: rpm-pkg, binrpm-pkg.  The
	# differences are as follows
	#
	#  - rpm-pkg intends to also provides source rpms
	#  - rpm-pkg will do $(MAKE) clean on each run...  No idea why is that
	#  - In recent kernel code, package kernel-devel will be disabled by mkspec
	#    if source package was not to be built or CONFIG_MODULES was not
	#    enabled.
	#
	cd "$PKG_BUILD_DIR/src"
	$MAKEJ \
		ARCH=x86_64 \
		LOCALVERSION=-bs \
		KDEB_PKGVERSION=$PKG_VERSION-1 \
		RPMOPTS="${rpmopts[*]}" \
			binrpm-pkg
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
	local topdir="$PKG_BUILD_DIR/rpmbuild"
	local frpm

	__errmsg "List of packages"
	__errmsg ""
	for frpm in "$topdir/RPMS/x86_64/"*.rpm "$topdir/SRPMS/"*.rpm; do
		if [ -f "$frpm" ]; then
			__errmsg "	sudo rpm -ivh $frpm"
		fi
	done
	__errmsg "
On CentOS 6.5, boot may fail because of virtio_blk not being included in
the initramfs image

	dracut --force --add-drivers virtio_blk /boot/initramfs-${PKG_VERSION}-bs.img
	lsinitrd /boot/initramfs-${PKG_VERSION}-bs.img | grep virtio_blk

- module scsi_wait_scan not found kernel panic on boot, https://bugzilla.kernel.org/show_bug.cgi?id=60758
"
}
