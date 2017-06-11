#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=lame
PKG_VERSION=3.99.5
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/$PKG_NAME/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=84835b313d4a8b68f5349816d33e07ce
PKG_DEPENDS=nasm

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--enable-nasm
)
