#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libslz
PKG_VERSION="1.1.0"
PKG_SOURCE_VERSION="v$PKG_VERSION"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="http://git.1wt.eu/web?p=libslz.git;a=snapshot;h=$PKG_SOURCE_VERSION;sf=tbz2"
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)
