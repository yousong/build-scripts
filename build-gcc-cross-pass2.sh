#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
. "$PWD/utils-toolchain.sh"
toolchain_init_pkg gcc
PKG_NAME=gcc-cross-pass2
PKG_DEPENDS="glibc-cross"

. "$PWD/env.sh"
toolchain_init_vars_build_cross "$PKG_NAME"

CONFIGURE_ARGS="$CONFIGURE_ARGS				\\
	--build='$TRI_BUILD'					\\
	--host='$TRI_HOST'						\\
	--target='$TRI_TARGET'					\\
	--with-headers='$TOOLCHAIN_DIR/include'	\\
	--enable-languages=c,c++				\\
	--disable-multilib						\\
	--disable-nls							\\
	--enable-shared							\\
	--enable-threads						\\
	--disable-libgomp						\\
	--disable-libmudflap					\\
	--disable-libssp						\\
"

compile() {
	build_compile_make 'all'
}

staging() {
	local base="$PKG_STAGING_DIR$TOOLCHAIN_DIR"

	# GCC will install directory lib/ and lib64/ there which is at the moement
	# symbolic links created at the installation of binutils
	mkdir -p "$base/$TRI_TARGET"
	ln -s lib "$base/lib64"
	ln -s ../lib "$base/$TRI_TARGET/lib"
	ln -s ../lib "$base/$TRI_TARGET/lib64"

	build_staging 'install'
}
