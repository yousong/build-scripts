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

# libssp can be disabled here because we expect it to be provided by libc which
# is true with musl, bionic and glibc since 2.4.  See LIBC_PROVIDES_SSP in
# gcc/configure.ac and gcc/gcc.c for details.  When ssp is not provided by
# libc, the link step will link against libssp.a and libssp_noshared.a which
# can be provided by libssp/ provided by GCC.  However libssp is a target
# library depending on presence of libc and as such cannot be enabled on gcc
# pass1
#
# LTO is not a language but will be enabled by default because
# --enabled-default is the default.  We enable it explicitly just in case
CONFIGURE_ARGS="$CONFIGURE_ARGS				\\
	--build='$TRI_BUILD'					\\
	--host='$TRI_HOST'						\\
	--target='$TRI_TARGET'					\\
	--with-headers='$TOOLCHAIN_DIR/include'	\\
	--enable-languages=c,c++,go				\\
	--disable-multilib						\\
	--disable-nls							\\
	--enable-shared							\\
	--enable-threads						\\
	--enable-lto							\\
	--disable-libgomp						\\
	--disable-libmudflap					\\
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
