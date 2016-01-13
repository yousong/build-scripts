#!/bin/sh -e

PKG_NAME=redis
PKG_VERSION=3.0.6
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://download.redis.io/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=9a44ea6bff987d2113caea7761730376

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
