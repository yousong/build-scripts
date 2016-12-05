#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libjpeg-turbo
PKG_VERSION=1.5.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/libjpeg-turbo/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=3fc5d9b6a8bce96161659ae7a9939257
PKG_DEPENDS='nasm'

. "$PWD/env.sh"

CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--disable-silent-rules		\\
"
