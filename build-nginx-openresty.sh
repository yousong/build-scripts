#!/bin/bash -e
#
# Copyright 2015-2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=openresty
PKG_VERSION=1.11.2.5
PKG_SOURCE="openresty-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://openresty.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=bf796f06c07660fa7c7fdcd2d7cc6955
PKG_DEPENDS='openssl pcre zlib'

. "$PWD/env.sh"
. "$PWD/utils-nginx.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# NOTE: NGINX version ${PKG_VERSION%.*} was bundled
	patch -p0 <<"EOF"
--- bundle/nginx-1.11.2/auto/feature.orig	2015-12-22 20:52:59.000000000 +0800
+++ bundle/nginx-1.11.2/auto/feature	2015-12-22 20:53:37.000000000 +0800
@@ -39,8 +39,8 @@ int main() {
 END
 
 
-ngx_test="$CC $CC_TEST_FLAGS $CC_AUX_FLAGS $ngx_feature_inc_path \
-          -o $NGX_AUTOTEST $NGX_AUTOTEST.c $NGX_TEST_LD_OPT $ngx_feature_libs"
+ngx_test="$CC $ngx_feature_inc_path $CC_TEST_FLAGS $CC_AUX_FLAGS \
+          -o $NGX_AUTOTEST $NGX_AUTOTEST.c $ngx_feature_libs $NGX_TEST_LD_OPT"
 
 ngx_feature_inc_path=
 
--- bundle/lua-rds-parser-0.06/Makefile.orig	2016-02-01 00:34:36.000000000 +0800
+++ bundle/lua-rds-parser-0.06/Makefile	2016-02-01 00:35:28.000000000 +0800
@@ -21,7 +21,7 @@ LUA_LIB_DIR ?=     $(PREFIX)/lib/lua/$(L
 
 #CFLAGS ?=          -g -Wall -pedantic -fno-inline
 CFLAGS ?=          -g -O -Wall
-override CFLAGS += -fpic -I$(LUA_INCLUDE_DIR)
+override CFLAGS := -fpic -I$(LUA_INCLUDE_DIR) $(CFLAGS)
 
 INSTALL ?= install
 
--- bundle/lua-redis-parser-0.13/Makefile.orig	2016-02-01 00:32:18.000000000 +0800
+++ bundle/lua-redis-parser-0.13/Makefile	2016-02-01 00:33:01.000000000 +0800
@@ -21,7 +21,7 @@ LUA_LIB_DIR ?=     $(PREFIX)/lib/lua/$(L
 
 #CFLAGS ?=          -g -Wall -pedantic -fno-inline
 CFLAGS ?=          -g -O -Wall
-override CFLAGS += -fpic -I$(LUA_INCLUDE_DIR)
+override CFLAGS := -fpic -I$(LUA_INCLUDE_DIR) $(CFLAGS)
 
 INSTALL ?= install
 
EOF
}

openrestry_configure_args() {
	local t=()
	local arg arg_

	# the configure script of openresty will configure nginx build with
	# "$NGINX_PREFIX/nginx" and as such we should not set --sbin-path etc. as
	# it may break openrestry configure script's expectation, e.g. simply
	# linking "bin/openresty" to "nginx"
	for arg in "${CONFIGURE_ARGS[@]}"; do
		arg_="${arg%%=*}"
		arg_="${arg_##*-}"
		if [ "$arg_" != path ]; then
			t+=( "$arg" )
		fi
	done
	CONFIGURE_ARGS=( "${t[@]}" )

	# luajit for example will be built in the configure stage and the configure
	# script actually accepts a -j option in the same spirit of GNU make
	CONFIGURE_ARGS+=(
		-j"$NJOBS"
		--with-pcre-jit
		--with-ipv6
		--with-http_realip_module
		--with-http_ssl_module
		--with-http_stub_status_module
		--with-http_v2_module
	)
}
openrestry_configure_args
