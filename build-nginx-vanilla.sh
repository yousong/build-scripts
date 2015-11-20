#!/bin/sh -e

# NGINX does not support out of tree build.
#
#

PKG_NAME=nginx
PKG_VERSION="1.9.6"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://nginx.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="f6899825e7a8deadba4948ff84515ad6"

. "$PWD/env.sh"

# nginx-lua depends on LuaJIT, LuaJIT.  They has to be preinstalled.
#
# If they are installed on Mac OS X with MacPorts (luajit)
if os_is_darwin; then
	CONFIGURE_VARS="											\\
		LUAJIT_LIB='$MACPORTS_PREFIX/lib'						\\
		LUAJIT_INC='$MACPORTS_PREFIX/include/luajit-2.0'		\\
"
fi
CONFIGURE_ARGS='					\
	--sbin-path=nginx				\
	--conf-path=nginx.conf			\
	--pid-path=nginx.pid			\
	--error-log-path=error.log		\
	--http-log-path=access.log		\
	--with-http_ssl_module			\
	--with-http_mp4_module			\
'

# master:agentzh/dns-nginx-module cannot build with NGINX 1.9.6 because of API change
MODS='
	master:chaoslawful/lua-nginx-module
	master:simpl/ngx_devel_kit
	master:agentzh/array-var-nginx-module
	master:agentzh/echo-nginx-module
	master:agentzh/headers-more-nginx-module
	master:agentzh/memc-nginx-module
	master:agentzh/rds-csv-nginx-module
	master:agentzh/rds-json-nginx-module
	master:agentzh/redis2-nginx-module
	master:agentzh/set-misc-nginx-module
	master:agentzh/xss-nginx-module
'

.  "$PWD/utils-nginx.sh"
nginx_add_modules

install_do() {
	cd "$PKG_BUILD_DIR"
	make DESTDIR="$_PKG_STAGING_DIR" install
}

main
