#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=gcc-pass1
PKG_VERSION=6.1.0
PKG_SOURCE="gcc-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://ftpmirror.gnu.org/gcc/gcc-$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=8fb6cb98b8459f5863328380fbf06bd1
PKG_DEPENDS="gcc-pass0 binutils"

. "$PWD/env.sh"
. "$PWD/utils-toolchain.sh"
toolchain_init

download() {
	true
}

prepare() {
	true
}

clean() {
	rm -rf "$PKG_BUILD_DIR"
}

configure_pre() {
	toolchain_configure_pre
}

#
# The following languages will be built: c,c++,fortran,java,lto,objc
# *** This configuration is not supported in the following subdirectories:
#      target-libmpx gnattools gotools target-libada target-libgo target-libbacktrace target-liboffloadmic
#     (Any other directories should still work fine.)
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
