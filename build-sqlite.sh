#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=sqlite
PKG_VERSION=autoconf-3100100
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://www.sqlite.org/2016/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=f315a86cb3e8671fe473baa8d34746f6
PKG_DEPENDS=ncurses

. "$PWD/env.sh"

# it's tgetent() or readline() it wants, not the libreadline library
CONFIGURE_ARGS+=(
	--enable-readline
	--enable-json1
)
