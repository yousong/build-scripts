#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=dtc
PKG_VERSION=1.5.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://mirrors.edge.kernel.org/pub/software/utils/$PKG_NAME/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d5b67727ee6d168fd83023e995565341

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
	NO_PYTHON=1
)
