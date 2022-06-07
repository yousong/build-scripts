#!/bin/bash -e
#
# Copyright 2016-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=nettle
PKG_VERSION=3.6
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://ftp.gnu.org/gnu/nettle/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=c45ee24ed7361dcda152a035d396fe8a
PKG_DEPENDS=gmp

. "$PWD/env.sh"

configure_static_build() {
	CONFIGURE_ARGS+=(
		--enable-static
	)
}
