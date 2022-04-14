#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libtirpc
PKG_VERSION=1.3.2
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="https://downloads.sourceforge.net/$PKG_NAME/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=cf4ca51f3fc401bea61c702c69171ab0

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--disable-gssapi
)
