#!/bin/sh -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=john
PKG_VERSION=1.8.0
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="http://www.openwall.com/john/j/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a4086df68f51778782777e60407f1869

NJOBS=1
. "$PWD/env.sh"

configure() {
	true
}

# Makefile of john does not provide install target at the moment.  See variable
# PROG in src/Makefile for details
staging() {
	true
}

install() {
	true
}

if os_is_linux; then
	JOHN_SYSTEM=linux-x86-64-avx
elif os_is_darwin; then
	JOHN_SYSTEM=macosx-x86-sse2
else
	__errmsg "unknown system"
fi

MAKE_ARGS="					\\
	-C '$PKG_BUILD_DIR/src'	\\
	clean $JOHN_SYSTEM		\\
"
