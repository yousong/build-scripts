#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=ffmpeg
PKG_VERSION=3.1.1
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="http://ffmpeg.org/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=bee939350e80e07c3d63285d0873b66b
PKG_DEPENDS='bzip2 zlib'

. "$PWD/env.sh"

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--enable-shared					\\
	--disable-yasm					\\
"
