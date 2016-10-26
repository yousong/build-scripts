#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
. "$PWD/utils-toolchain.sh"
toolchain_init_pkg binutils
PKG_NAME=binutils-native-pass1
PKG_DEPENDS='binutils-pass0'

. "$PWD/env.sh"

toolchain_init_vars_build_native "$PKG_NAME"

staging_post() {
	local base="$PKG_STAGING_DIR$INSTALL_PREFIX/binutils-pass1"

	mkdir -p "$base/usr/include"
	ln -sf 'lib' "$base/lib64"
	ln -sf '../lib' "$base/$TRI_TARGET/lib64"
	ln -sf '../lib' "$base/$TRI_TARGET/lib"
}
