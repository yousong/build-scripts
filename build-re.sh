#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=re
PKG_VERSION=0.5.2
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://www.creytiv.com/pub/re-0.5.2.tar.gz"
PKG_SOURCE_MD5SUM=bea471d6130512d834bf706ea407a090
PKG_DEPENDS='zlib openssl'

. "$PWD/env.sh"

configure() {
	true
}

# we already set CFLAGS as environment variable which will be appended to by
# the package Makefile, so there is no need to set EXTRA_CFLAGS
MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
	RELEASE=1
	EXTRA_LFLAGS="${EXTRA_LDFLAGS[*]}"
)
