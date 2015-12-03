#!/bin/sh -e

PKG_NAME=redis
PKG_VERSION="3.0.5"
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://download.redis.io/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="c7ba233e5f92ad2f48860c815bb05480"

. "$PWD/env.sh"

# verbose output instead of colorful output for better logging
MAKE_VARS="V=1"
# openresty is self-contained
if os_is_darwin; then
	EXTRA_CPPFLAGS=""
	EXTRA_CFLAGS=""
	EXTRA_LDFLAGS=""
fi

build_configure() {
	true
}

install_staging() {
	cd "$PKG_BUILD_DIR"
	# build system of redis just install all its binaries in bin/ directory
	make PREFIX="$_PKG_STAGING_DIR" install
}

install_to_final() {
	mkdir -p "$INSTALL_PREFIX"
	cp "$_PKG_STAGING_DIR" "$INSTALL_PREFIX"
}

main
