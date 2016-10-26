#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
. "$PWD/utils-toolchain.sh"
toolchain_init_pkg gcc
PKG_NAME=gcc-cross-pass1
PKG_DEPENDS="gcc-pass0 binutils-cross"

. "$PWD/env.sh"
toolchain_init_vars_build_cross

CONFIGURE_ARGS="$CONFIGURE_ARGS				\\
	--build='$TRI_BUILD'					\\
	--host='$TRI_HOST'						\\
	--target='$TRI_TARGET'					\\
	--with-newlib							\\
	--without-headers						\\
	--without-isl							\\
	--without-cloog							\\
	--enable-languages=c					\\
	--disable-multilib						\\
	--disable-nls							\\
	--disable-shared						\\
	--disable-decimal-float					\\
	--disable-threads						\\
	--disable-libatomic						\\
	--disable-libgomp						\\
	--disable-libmpx						\\
	--disable-libmudflap					\\
	--disable-libquadmath					\\
	--disable-libsanitizer					\\
	--disable-libssp						\\
	--disable-libstdcxx						\\
	--disable-libvtv						\\
"

compile() {
	# looks like all-target-libgcc depends on all-gcc to
	# build gcc/xgcc but the dependency is not present in
	# Makefile.tpl so that we cannot make them in a single
	# command
	build_compile_make 'all-gcc'
	build_compile_make 'all-target-libgcc'
}

staging() {
	build_staging 'install-gcc' 'install-target-libgcc'
}
