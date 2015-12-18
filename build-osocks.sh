#!/bin/sh -e
#
# osocks depends on libubox
#
PKG_NAME=osocks
PKG_VERSION="2015-11-20"
PKG_SOURCE_VERSION="387c949b8a2b2392aacf6cbb8293deccc5daf115"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-${PKG_SOURCE_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/yousong/osocks/archive/${PKG_SOURCE_VERSION}.tar.gz"
PKG_SOURCE_MD5SUM=""
PKG_CMAKE=1

. "$PWD/env.sh"

prepare_source() {
	local dir="$(basename $PKG_BUILD_DIR)"
	untar "$BASE_DL_DIR/$PKG_SOURCE" "$BASE_BUILD_DIR" "s:^[^/]\\+:$dir:"
}

