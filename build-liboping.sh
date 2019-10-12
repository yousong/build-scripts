#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=liboping
PKG_VERSION=1.10.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://noping.cc/files/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=54e0f5a1aaf9eabf3f412d2fdc9c6831
PKG_DEPENDS='ncurses'

. "$PWD/env.sh"
