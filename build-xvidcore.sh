#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=xvidcore
PKG_VERSION=1.3.4
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://downloads.xvid.org/downloads/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=8cf4a42f280b03dae452080ef9e7c798
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

PKG_BUILD_DIR="$PKG_SOURCE_DIR/build/generic"
CONFIGURE_PATH="$PKG_SOURCE_DIR/build/generic"
CONFIGURE_CMD="./configure"
