#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# - Compilation Guide, https://trac.ffmpeg.org/wiki/CompilationGuide
#
PKG_NAME=ffmpeg
PKG_VERSION=3.1.1
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="http://ffmpeg.org/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=bee939350e80e07c3d63285d0873b66b
PKG_DEPENDS='bzip2 fdk-aac x264 x265 yasm zlib'

. "$PWD/env.sh"

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--enable-shared					\\
	--enable-gpl					\\
	--enable-nonfree				\\
	--enable-libfdk-aac				\\
	--enable-libx264				\\
	--enable-libx265				\\
	--enable-libmp3lame				\\
"
