#!/bin/bash -e
#
# Copyright 2020 (c) Yousong Zhou
#
# Checking CMakeLists.txt, it seems openssl is an optional dependency
# for ctest
#
PKG_NAME=ninja
PKG_VERSION=1.10.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/ninja-build/ninja/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=cf1d964113a171da42a8940e7607e71a
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='python3'

. "$PWD/env.sh"

CONFIGURE_CMD=./configure.py
CONFIGURE_ARGS=(
	--bootstrap
)

compile() {
	# Compile and link by ./configure.py
	:
}

staging() {
	local d="$PKG_STAGING_DIR/$INSTALL_PREFIX/bin"
	mkdir -p "$d"
	cp "$PKG_BUILD_DIR/ninja" "$d"
}
