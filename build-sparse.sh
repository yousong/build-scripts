#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=sparse
PKG_VERSION=0.5.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://www.kernel.org/pub/software/devel/sparse/dist/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=68bc834c57836251fbee55a7707bab39

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)
