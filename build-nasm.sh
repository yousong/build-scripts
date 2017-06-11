#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=nasm
PKG_VERSION=2.12.02
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="http://www.nasm.us/pub/nasm/releasebuilds/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d15843c3fb7db39af80571ee27ec6fad

. "$PWD/env.sh"

MAKE_VARS+=(
	INSTALLROOT="$PKG_STAGING_DIR"
)
