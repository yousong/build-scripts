#!/bin/bash -e
#
# Copyright 2016-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=haproxy
PKG_VERSION=1.8.13
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.haproxy.org/download/${PKG_VERSION%.*}/src/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=bf0b437bad78f5824d7e26ae0c81fee4
PKG_DEPENDS='lua5.3 openssl pcre zlib'

. "$PWD/env.sh"

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
