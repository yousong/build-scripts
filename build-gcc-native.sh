#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=gcc-native
PKG_VERSION=6.1.0
PKG_SOURCE="gcc-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://ftpmirror.gnu.org/gcc/gcc-$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=8fb6cb98b8459f5863328380fbf06bd1
PKG_DEPENDS="glibc-native binutils-native gcc-pass0"

. "$PWD/env.sh"

if [ "$PKG_NAME" != "${PKG_SOURCE%%-*}" ]; then
	PKG_BUILD_DIR="$BASE_BUILD_DIR/$PKG_NAME"
fi

EXTRA_LDFLAGS="$EXTRA_LDFLAGS  -Wl,--dynamic-linker=$INSTALL_PREFIX/lib/ld-linux-x86-64.so.2"
CONFIGURE_PATH="$PKG_BUILD_DIR"
CONFIGURE_CMD="$PKG_SOURCE_DIR/configure"

clean() {
	rm -rf "$PKG_BUILD_DIR"
}

configure_pre() {
	mkdir -p "$PKG_BUILD_DIR"
}

CONFIGURE_ARGS="$CONFIGURE_ARGS				\\
	--enable-languages=c,c++				\\
	--disable-multilib						\\
	--disable-nls							\\
	--enable-shared							\\
	--enable-threads						\\
	--disable-libgomp						\\
	--disable-libmudflap					\\
"

compile() {
	build_compile_make 'all'
}

staging() {
	local base="$PKG_STAGING_DIR$INSTALL_PREFIX"

	# GCC will install directory lib/ and lib64/ there which is at the moement
	# symbolic links created at the installation of binutils
	mkdir -p "$base"
	ln -sf lib "$base/lib64"

	build_staging 'install'
}
