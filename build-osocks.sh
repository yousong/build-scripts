#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=osocks
PKG_VERSION=2015-11-20
PKG_SOURCE_VERSION=387c949b8a2b2392aacf6cbb8293deccc5daf115
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/yousong/osocks/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_CMAKE=1
PKG_DEPENDS='libubox'

. "$PWD/env.sh"
