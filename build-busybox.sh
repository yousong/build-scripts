#!/bin/bash -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Install a statically linked busybox binary to $INSTALL_PREFIX/bin
#
# Static busybox needs static library dependencies and on CentOS6 we need
#
#	yum install -y glibc-static
#
# In case those applets are installed accidentally as symbolic links
#
#	for f in $(find . -type l) ; do i="$(readlink -f "$f")"; i="$(basename "$i")"; [ "$i" = busybox ] && rm -vf $f; done
#
PKG_NAME=busybox
PKG_VERSION=1.27.2
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="https://busybox.net/downloads/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=476186f4bab81781dab2369bfd42734e
PKG_PLATFORM=linux

. "$PWD/env.sh"
. "$PWD/utils-kconfig.sh"

EXTRA_CFLAGS=()
EXTRA_CPPFLAGS=()
EXTRA_LDFLAGS=()

configure() {
	cd "$PKG_BUILD_DIR"
	if [ -s ".config" ]; then
		mv ".config" ".config.old"
	fi
	# 1. link statically
	# 2. syncfs() for fancy sync is not available in debian wheezy 3.2.0 kernel, so disable it
	make defconfig
	kconfig_set_option CONFIG_STATIC y
	kconfig_set_option CONFIG_FEATURE_SYNC_FANCY n
	kconfig_set_option CONFIG_INSTALL_APPLET_SYMLINKS n
	kconfig_set_option CONFIG_INSTALL_APPLET_DONT y
	kconfig_set_option CONFIG_PREFIX "\"$PKG_STAGING_DIR/$INSTALL_PREFIX\""
	#
	# The setns() system call first appeared in Linux in kernel 3.0;
	# library support was added to glibc in version 2.14.
	kconfig_set_option CONFIG_NSENTER n
}

#MAKE_VARS+=(
#	V=1
#)
