#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
. "$PWD/utils-toolchain.sh"
toolchain_init_pkg gcc
PKG_NAME=gcc-native
PKG_DEPENDS="glibc-native binutils-native-pass2 gcc-pass0"

. "$PWD/env.sh"

toolchain_init_vars_build_native

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--enable-languages=c,c++		\\
	--disable-multilib				\\
	--disable-nls					\\
	--enable-shared					\\
	--enable-threads				\\
	--disable-libgomp				\\
	--disable-libmudflap			\\
"

#CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
#	--disable-bootstrap				\\
#"

MAKE_VARS="$MAKE_VARS				\\
	BOOT_LDFLAGS='$EXTRA_LDFLAGS'	\\
"

compile() {
	build_compile_make 'all'
}

staging() {
	local base="$PKG_STAGING_DIR$INSTALL_PREFIX"

	mkdir -p "$base"
	ln -sf lib "$base/lib64"

	build_staging 'install'
}
