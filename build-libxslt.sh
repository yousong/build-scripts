#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libxslt
PKG_VERSION=1.1.33
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="ftp://xmlsoft.org/libxml2/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b3bd254a03e46d58f8ad1e4559cd2c2f
PKG_DEPENDS='libxml'

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--disable-silent-rules
	--without-python
)
