#!/bin/bash -e
#
# Copyright 2019-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# > headers defining protocols
#
PKG_NAME=spice
PKG_VERSION=0.14.3
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="https://www.spice-space.org/download/releases/spice-server/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a776650f7c4dc22681d76308475a9190
PKG_DEPENDS='libjpeg-turbo openssl pixman spice-protocol zlib'

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	# audio codecs
	--disable-opus
	--disable-celt051
)
