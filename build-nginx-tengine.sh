#!/bin/sh -e

PKG_NAME=tengine
PKG_VERSION=2.1.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://tengine.taobao.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=76af6a4969e7179c2ff4512d31d9e12d
PKG_DEPENDS='openssl pcre zlib'

. "$PWD/env.sh"
. "$PWD/utils-nginx.sh"

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--with-http_ssl_module			\\
	--with-http_mp4_module			\\
	--with-http_v2_module			\\
"
