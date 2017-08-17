#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=node
PKG_VERSION=6.11.2
PKG_SOURCE="$PKG_NAME-v${PKG_VERSION}-linux-x64.tar.xz"
PKG_SOURCE_URL="https://nodejs.org/dist/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a7c61eeed0c49951cc071f3d27c0ebc7
PKG_PLATFORM=linux

. "$PWD/env.sh"

configure() {
	true
}

compile() {
	true
}

staging() {
	local dd="$PKG_STAGING_DIR$INSTALL_PREFIX"
	local d

	for d in bin include lib share; do
		mkdir -p "$dd/$d"
		cpdir "$PKG_BUILD_DIR/$d" "$dd/$d"
	done
}
