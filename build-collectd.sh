#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=collectd
PKG_VERSION=5.9.0
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="https://github.com/collectd/collectd/releases/download/$PKG_NAME-$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=84fbc1940b90ad34c10870c3187d7022
PKG_DEPENDS='libiconv liboping LuaJIT ncurses python2 python3'

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--disable-silent-rules
)

if false; then
	#env_init_llvm_toolchain
	EXTRA_CFLAGS+=(
		-fsanitize=address
	)
fi
