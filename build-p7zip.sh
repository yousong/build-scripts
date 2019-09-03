#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# README in the source code is quite informative
#
#	7z uses plugins (7z.so and Codecs/Rar.so) to handle archives.
#	7za is a stand-alone executable (7za handles less archive formats than 7z).
#	7zr is a light stand-alone executable that supports only 7z/LZMA/BCJ/BCJ2.
#
PKG_NAME=p7zip
PKG_VERSION=16.02
PKG_SOURCE="${PKG_NAME}_${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="https://downloads.sourceforge.net/p7zip/${PKG_NAME}_${PKG_VERSION}_src_all.tar.bz2"
PKG_SOURCE_MD5SUM=a0128d661cfe7cc8c121e73519c54fbf

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS+=(
	DEST_DIR="$PKG_STAGING_DIR"
	DEST_HOME="$INSTALL_PREFIX"
)

compile() {
	cd "$PKG_BUILD_DIR"
	build_compile_make "all3"
}
