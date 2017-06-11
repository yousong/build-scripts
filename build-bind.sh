#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=bind
PKG_VERSION=9.9.8-P3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="ftp://ftp.isc.org/isc/bind9/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=30b9bf88a78eee783d3fef5257445788
PKG_DEPENDS='openssl zlib'

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--with-openssl="$INSTALL_PREFIX"
)
