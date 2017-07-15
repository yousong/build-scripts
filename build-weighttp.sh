#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=weighttp
PKG_VERSION=0.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/lighttpd/weighttp/archive/$PKG_SOURCE"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libev'

. "$PWD/env.sh"

configure_pre() {
	cd "$PKG_SOURCE_DIR"
	bash -e ./autogen.sh
}
