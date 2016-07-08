#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=redis
PKG_VERSION=3.2.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://download.redis.io/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b311d4332326f1e6f86a461b4025636d

. "$PWD/env.sh"

# verbose output instead of colorful output for better logging
MAKE_VARS="V=1"
# redis has its own Lua source packaged and is almost self-contained
if os_is_darwin; then
	EXTRA_CPPFLAGS=""
	EXTRA_CFLAGS=""
	EXTRA_LDFLAGS=""
fi

configure() {
	true
}

staging() {
	cd "$PKG_BUILD_DIR"
	# build system of redis just install all its binaries in bin/ directory
	$MAKEJ PREFIX="$PKG_STAGING_DIR/$INSTALL_PREFIX" install
}
