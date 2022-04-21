#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=unzip
PKG_VERSION=6.0
PKG_SOURCE="${PKG_NAME}${PKG_VERSION/./}.tar.gz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/infozip/${PKG_SOURCE}"
PKG_SOURCE_MD5SUM=62b490407489521db863b523a7f86375

. "$PWD/env.sh"

configure() {
	true
}

unzip_make() {
	local CC
	local arg

	for arg in "${CONFIGURE_VARS[@]}"; do
		CC="${arg#CC=}"
		if test "$CC" != "$arg"; then
			break
		fi
	done

	cd "$PKG_BUILD_DIR"
	build_compile_make \
		-f "unix/Makefile" \
		${CC:+"CC=$CC"} \
		CFLAGS="${EXTRA_CPPFLAGS[*]} ${EXTRA_CFLAGS[*]}" \
		LFLAGS1="${EXTRA_LDFLAGS[*]}" \
		"$@"
}

compile() {
	unzip_make \
		prefix="$INSTALL_PREFIX" \
		generic
}

staging() {
	unzip_make \
		prefix="$PKG_STAGING_DIR$INSTALL_PREFIX" \
		install
}
