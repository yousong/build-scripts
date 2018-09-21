#!/bin/bash -e
#
# Copyright 2016-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Use Vim syntax file
#
#	wget https://www.haproxy.org/download/contrib/haproxy.vim
#	mv haproxy.vim ~/.usr/share/vim/vim80/syntax/
#	# vi: ft=haproxy
#
# TODO use libslz
#
PKG_NAME=haproxy
PKG_VERSION=1.8.14
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.haproxy.org/download/${PKG_VERSION%.*}/src/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a050bcb90426d1c939b4b0ce3098a8c4
PKG_DEPENDS='lua5.3 openssl pcre zlib'

. "$PWD/env.sh"

do_patch(){
	cd "$PKG_SOURCE_DIR"
	# the patch is for
	#
	#	make contrib/halog/halog
	#
	patch -p0 <<"EOF"
--- Makefile.orig       2018-08-16 15:37:36.807599920 +0000
+++ Makefile    2018-08-16 15:37:52.450439948 +0000
@@ -908,6 +908,9 @@ objsize: haproxy
 %.o:   %.c $(DEP)
 	$(CC) $(COPTS) -c -o $@ $<

+contrib/%:
+	$(MAKE) -C $(dir $@)
+
 src/trace.o: src/trace.c $(DEP)
 	$(CC) $(TRACE_COPTS) -c -o $@ $<

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
	LDFLAGS="${EXTRA_LDFLAGS[*]}"
	USE_PCRE=1
	USE_PCRE_JIT=1
	USE_REGPARM=1
	USE_OPENSSL=1
	USE_ZLIB=1
)

if false; then
	# IP_BIND_ADDRESS_NO_PORT is available since Linux 4.2, or CentOS 7.4 (3.10.693)
	MAKE_VARS+=(
		DEFINE="-DIP_BIND_ADDRESS_NO_PORT=24"
	)
fi

#with sd_notify in mind, requires -lsystemd
#MAKE_VARGS+=(USE_SYSTEMD=1)

MAKE_VARS+=(
	EXTRA="contrib/halog/halog"
)

haproxy_use_lua() {
	local inc="$(pkg-config --cflags-only-I lua5.3 2>/dev/null | sed -e 's/-I//g')"
	local lib="$(pkg-config --libs lua5.3 2>/dev/null)"

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
