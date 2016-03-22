#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=mpfr
PKG_VERSION=3.1.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://www.mpfr.org/mpfr-current/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=064b2c18185038e404a401b830d59be8
PKG_DEPENDS=gmp

. "$PWD/env.sh"
