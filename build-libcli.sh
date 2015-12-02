#!/bin/sh -e

PKG_NAME=libcli
PKG_VERSION="1.9.7"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://github.com/dparrish/libcli/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM="f33e0fdb8ae8e14e66036424704b201b"

. "$PWD/env.sh"

build_configure() {
	true
}

install_staging() {
	cd "$PKG_BUILD_DIR"
	make DESTDIR="$_PKG_STAGING_DIR" PREFIX="$INSTALL_PREFIX" install
}

main
