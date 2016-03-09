#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# See usage text for "Compiled-in tests"
#
#		./sysbench/sysbench --test=cpu help
#		./sysbench/sysbench --test=cpu run
#
PKG_NAME=sysbench
PKG_VERSION=0.5
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/akopytov/sysbench/archive/$PKG_VERSION.tar.gz"

. "$PWD/env.sh"
if os_is_linux; then
	PKG_DEPENDS="$PKG_DEPENDS libaio"
fi

configure_pre() {
	cd "$PKG_SOURCE_DIR"
	./autogen.sh
}

# sysbench includes lua source code in sysbench/scripting/lua.  Drizzle and
# libattachsql support still requires those two libraries first
#
#	checking whether to compile with MySQL support... (cached) no
#	checking whether to compile with Drizzle support... (cached) yes
#	checking whether to compile with libattachsql support... (cached) yes
#	checking whether to compile with Oracle support... (cached) no
#	checking whether to compile with PostgreSQL support... (cached) no
#
CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--without-mysql				\\
"
