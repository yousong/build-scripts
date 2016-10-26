#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=kernel-headers
PKG_VERSION=4.4.13
PKG_SOURCE="linux-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://cdn.kernel.org/pub/linux/kernel/v${PKG_VERSION%%.*}.x/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d70b6959d8db61bcea7070c089aace9b
PKG_PLATFORM=linux

. "$PWD/env.sh"
. "$PWD/utils-toolchain.sh"
toolchain_init_vars_build_cross

configure() {
	true
}

compile() {
	true
}

staging() {
	# it is said that INSTALL_HDR_PATH will be cleaned up when making
	# headers_install, so the staging step here is actually required
	cd "$PKG_SOURCE_DIR"
	$MAKEJ INSTALL_HDR_PATH="$PKG_STAGING_DIR$INSTALL_PREFIX" headers_install
}

install() {
	mkdir -p "$TOOLCHAIN_DIR"
	cpdir "$PKG_STAGING_DIR$INSTALL_PREFIX" "$TOOLCHAIN_DIR"
}
