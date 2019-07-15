#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=mtr
PKG_VERSION=0.92
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/traviscross/mtr/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=f764793302a6cee2bf1573b95db6f295
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

prepare_extra() {
	echo "$PKG_VERSION" >"$PKG_SOURCE_DIR/.tarball-version"
}

CONFIGURE_ARGS+=(
	--enable-pcapconfig
)
