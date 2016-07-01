#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=glibc-native
PKG_VERSION=2.23
PKG_SOURCE="glibc-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://ftpmirror.gnu.org/glibc/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=456995968f3acadbed39f5eba31678df

. "$PWD/env.sh"

# ld-x86_64.so.2 does not like RPATH: will choke with
#
#	Inconsistency detected by ld.so: dl-lookup.c: 867: _dl_setup_hash: Assertion `(bitmask_nwords & (bitmask_nwords - 1)) == 0' failed!
#

EXTRA_CPPFLAGS=''
EXTRA_CFLAGS=''
EXTRA_LDFLAGS=''

if [ "$PKG_NAME" != "${PKG_SOURCE%%-*}" ]; then
	PKG_BUILD_DIR="$BASE_BUILD_DIR/$PKG_NAME"
fi
CONFIGURE_PATH="$PKG_BUILD_DIR"
CONFIGURE_CMD="$PKG_SOURCE_DIR/configure"

clean() {
	rm -rf "$PKG_BUILD_DIR"
}

configure_pre() {
	mkdir -p "$PKG_BUILD_DIR"
}

CONFIGURE_ARGS="$CONFIGURE_ARGS					\\
	--enable-kernel=2.6.32						\\
	--disable-werror							\\
"

EXTRA_CFLAGS="$EXTRA_CFLAGS -O2"
