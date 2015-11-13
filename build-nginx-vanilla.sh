#!/bin/sh -e

PKG_NAME=nginx
PKG_VERSION="1.9.6"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://nginx.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="f6899825e7a8deadba4948ff84515ad6"

. "$PWD/env.sh"

CONFIGURE_ARGS='					\
	--sbin-path=nginx				\
	--conf-path=nginx.conf			\
	--pid-path=nginx.pid			\
	--error-log-path=error.log		\
	--http-log-path=access.log		\
	--with-http_ssl_module			\
	--with-http_mp4_module			\
'

install_do() {
	cd "$PKG_BUILD_DIR"
	make DESTDIR="$_PKG_STAGING_DIR" install
}

main
