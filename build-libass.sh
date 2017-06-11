#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libass
PKG_VERSION=0.13.2
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://github.com/libass/libass/releases/download/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1c8cbd5751aeb192bda04a65d0464fd9
PKG_DEPENDS="fribidi yasm"

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--disable-require-system-font-provider
)
