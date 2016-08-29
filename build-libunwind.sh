#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libunwind
PKG_VERSION=1.1
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://download.savannah.gnu.org/releases/libunwind/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=fb4ea2f6fbbe45bf032cd36e586883ce
PKG_PLATFORM=linux

. "$PWD/env.sh"
