#!/bin/bash -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libcli
PKG_VERSION="1.9.7"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://github.com/dparrish/libcli/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM="f33e0fdb8ae8e14e66036424704b201b"

. "$PWD/env.sh"

configure() {
	true
}

staging() {
	cd "$PKG_BUILD_DIR"
	"${MAKEJ[@]}" DESTDIR="$PKG_STAGING_DIR" PREFIX="$INSTALL_PREFIX" install
}

