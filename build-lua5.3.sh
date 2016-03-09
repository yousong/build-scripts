#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=lua5.3
PKG_VERSION=5.3.2
PKG_SOURCE="lua-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.lua.org/ftp/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=33278c2ab5ee3c1a875be8d55c1ca2a1
PKG_BUILD_DIR_BASENAME="lua-$PKG_VERSION"

. "$PWD/env.sh"
. "$PWD/utils-lua.sh"
