#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libaio
PKG_VERSION="0.3.110-1"
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/crossbuild/libaio/archive/$PKG_SOURCE"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PLATFORM=linux

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS+=(
	prefix="$PKG_STAGING_DIR$INSTALL_PREFIX"
)
