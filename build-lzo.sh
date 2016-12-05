#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=lzo
PKG_VERSION=2.09
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.oberhumer.com/opensource/lzo/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=c7ffc9a103afe2d1bba0b015e7aa887f

. "$PWD/env.sh"

CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--enable-shared				\\
"
