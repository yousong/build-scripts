#!/bin/bash -e
#
# Copyright 2016-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Might as well just try universal-ctags or rewrite another one.  Should be fun
# trying those lexer things
#
# - https://github.com/universal-ctags/ctags
#
PKG_NAME=ctags
PKG_VERSION=p5.9.20210808.0
PKG_SOURCE="universal-ctags-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/universal-ctags/ctags/archive/refs/tags/$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=ea0af2a74e494c26b3f9911c29c14d49
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

configure_pre() {
	cd "$PKG_BUILD_DIR"
	ls
	./autogen.sh
}
