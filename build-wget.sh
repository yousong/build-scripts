#!/bin/bash -e
#
# Copyright 2016-2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=wget
PKG_VERSION=1.19.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/wget/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d30d82186b93fcabb4116ff513bfa9bd
PKG_DEPENDS='libiconv openssl pcre zlib'

. "$PWD/env.sh"

# Wget defaults to GNU TLS but that requires too many dependencies
CONFIGURE_ARGS+=(
	--disable-silent-rules
	--with-ssl=openssl
)
