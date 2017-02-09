#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=wget
PKG_VERSION=1.17.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/wget/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b0d58ef4963690e71effba24c105ed52
PKG_DEPENDS='libiconv openssl pcre zlib'

. "$PWD/env.sh"

# Wget defaults to GNU TLS but that requires too many dependencies
CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--disable-silent-rules		\\
	--with-ssl=openssl			\\
"
