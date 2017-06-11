#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=x264
PKG_VERSION=20160816-2245
PKG_SOURCE="$PKG_NAME-snapshot-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="http://download.videolan.org/pub/videolan/x264/snapshots/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=3bce82e73eff372942d5a7972951f7f4
PKG_DEPENDS="yasm"

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--enable-shared
)
