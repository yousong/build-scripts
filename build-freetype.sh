#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=freetype
PKG_VERSION=2.6.5
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="http://download.savannah.gnu.org/releases/$PKG_NAME/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=6a386964e18ba28cb93370e57a19031b
PKG_DEPENDS='bzip2 libpng zlib'

. "$PWD/env.sh"
