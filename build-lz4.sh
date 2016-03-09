#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=lz4
PKG_VERSION=r131
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/Cyan4973/lz4/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS="PREFIX='$INSTALL_PREFIX'"
# target 'all' includes binaries built with `-m32`
MAKE_ARGS='lz4programs lib'
