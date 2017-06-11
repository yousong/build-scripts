#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=haproxy
PKG_VERSION=1.6.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.haproxy.org/download/${PKG_VERSION%.*}/src/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=ee107312ef58432859ee12bf048025ab
PKG_DEPENDS='lua5.3 openssl pcre zlib'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- Makefile.orig	2016-03-18 11:20:12.921054841 +0800
+++ Makefile	2016-03-18 11:20:33.129060321 +0800
@@ -300,7 +300,6 @@ ifeq ($(TARGET),osx)
   USE_POLL       = implicit
   USE_KQUEUE     = implicit
   USE_TPROXY     = implicit
-  USE_LIBCRYPT   = implicit
 else
 ifeq ($(TARGET),openbsd)
   # This is for OpenBSD >= 3.0
@@ -705,7 +705,7 @@ endif
 #### Global link options
 # These options are added at the end of the "ld" command line. Use LDFLAGS to
 # add options at the beginning of the "ld" command line if needed.
-LDOPTS = $(TARGET_LDFLAGS) $(OPTIONS_LDFLAGS) $(ADDLIB)
+LDOPTS = $(TARGET_LDFLAGS) $(OPTIONS_LDFLAGS) $(ADDLIB) $(EXTRA_LDFLAGS)
 
 ifeq ($(TARGET),)
 all:
EOF
}

if os_is_linux; then
	MAKE_VARS+=(
		TARGET=linux2628
	)
elif os_is_darwin; then
	MAKE_VARS+=(
		TARGET=osx
	)
fi
MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
	EXTRA_LDFLAGS="${EXTRA_LDFLAGS[*]}"
	USE_PCRE=1
	USE_PCRE_JIT=1
	USE_REGPARM=1
	USE_OPENSSL=1
	USE_ZLIB=1
)

haproxy_use_lua() {
	local inc="$(pkg-config --cflags-only-I lua5.3 | sed -e 's/-I//g')"
	local lib="$(pkg-config --libs lua5.3)"

	MAKE_VARS+=(
		USE_LUA=1
		LUA_LIB_NAME=lua
		LUA_INC="$inc"
		LUA_LD_FLAGS="$lib"
	)
}
haproxy_use_lua

configure() {
	true
}
