#!/bin/sh -e
#
# osocks depends on libubox
#
PKG_NAME=osocks
PKG_VERSION="2015-06-04"
PKG_SOURCE_VERSION="ee30d986e07b7a3b0a254c15833128c19c0839c0"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-${PKG_SOURCE_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/yousong/osocks/archive/${PKG_SOURCE_VERSION}.tar.gz"
PKG_SOURCE_MD5SUM=""
PKG_CMAKE=1

. "$PWD/env.sh"

prepare_source() {
	local dir="$(basename $PKG_BUILD_DIR)"
	untar "$BASE_DL_DIR/$PKG_SOURCE" "$BASE_BUILD_DIR" "s:^[^/]\\+:$dir:"
}

main
