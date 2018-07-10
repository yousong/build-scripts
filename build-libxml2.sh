#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libxml2
PKG_VERSION=2.9.6
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="ftp://xmlsoft.org/libxml2/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=dbae8327d8471941bf0472e273473e36
PKG_DEPENDS='libiconv xz'

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--disable-silent-rules
	--without-python
)
