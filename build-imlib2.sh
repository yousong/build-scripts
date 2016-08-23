#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=imlib2
PKG_VERSION=1.4.9
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://downloads.sourceforge.net/enlightenment/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=23ef8b49f2793bc63b16839a2062298b
PKG_DEPENDS='bzip2 freetype libpng zlib'

. "$PWD/env.sh"
