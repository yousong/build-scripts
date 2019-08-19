#!/bin/bash -e
#
# Copyright 2016-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=lzo
PKG_VERSION=2.10
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.oberhumer.com/opensource/lzo/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=39d3f3f9c55c87b1e5d6888e1420f4b5

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--enable-shared
)
