#!/bin/sh -e

PKG_NAME=libuv
PKG_VERSION=1.8.0
PKG_SOURCE="$PKG_NAME-v${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://dist.libuv.org/dist/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=f4229c4360625e973ae933cb92e1faf7
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

configure_pre() {
	cd "$PKG_BUILD_DIR"
	sh -e autogen.sh
}
