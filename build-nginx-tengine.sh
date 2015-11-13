#!/bin/sh -e

PKG_NAME=tengine
PKG_VERSION="2.1.0"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://tengine.taobao.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="fb60c57c2610c6a356153613c485e4af"

. "$PWD/env.sh"

CONFIGURE_ARGS='					\
	--sbin-path=nginx				\
	--conf-path=nginx.conf			\
	--pid-path=nginx.pid			\
	--error-log-path=error.log		\
	--http-log-path=access.log		\
'

install_do() {
	cd "$PKG_BUILD_DIR"
	make DESTDIR="$_PKG_STAGING_DIR" install
}

main
