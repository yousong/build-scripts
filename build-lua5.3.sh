#!/bin/bash -e
#
# Copyright 2016-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=lua5.3
PKG_VERSION=5.3.5
PKG_SOURCE="lua-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.lua.org/ftp/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=4f4b4f323fd3514a68e0ab3da8ce3455

. "$PWD/env.sh"
. "$PWD/utils-lua.sh"
