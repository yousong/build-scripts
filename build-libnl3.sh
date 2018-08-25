#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Netlink Protocol Library Suite (libnl), https://www.infradead.org/~tgr/libnl/
#
# > Support for 1.1.x releases is limited, backports are only done upon request.
# > Do not develop new applications based on libnl1 and consider porting your
# > applications to libnl3
#
PKG_NAME=libnl3
PKG_VERSION=3.2.25
PKG_SOURCE="libnl-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://www.infradead.org/~tgr/libnl/files/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=03f74d0cd5037cadc8cdfa313bbd195c
PKG_PLATFORM=linux

. "$PWD/env.sh"
