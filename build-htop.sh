#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=htop
PKG_VERSION=2.0.1
PKG_SOURCE="htop-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://hisham.hm/htop/releases/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=f75fe92b4defaa80d99109830f34b5e2
PKG_DEPENDS=ncurses

. "$PWD/env.sh"
