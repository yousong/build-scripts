#!/bin/sh -e

PKG_NAME=shadowsocks-libev
PKG_VERSION=2.4.5
PKG_SOURCE_VERSION=v2.4.5
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/shadowsocks/$PKG_NAME/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libev openssl zlib'

. "$PWD/env.sh"

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--with-pic						\\
	--enable-shared					\\
	--enable-static					\\
	--disable-silent-rules			\\
"
