#!/bin/bash -e
#
# Copyright 2019-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=dtc
PKG_VERSION=1.6.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://mirrors.edge.kernel.org/pub/software/utils/$PKG_NAME/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1556ba93648bf70d7aa034252e278751

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
	NO_PYTHON=1
)
