#!/bin/bash -e
#
# Copyright 2021 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Installed executables
#
#  nocache	shell script run cmd with LD_PRELOAD nocache.so
#  cachestats	pagecache stats of specified file
#  cachedel	eradicate pagecache presence of a file
#
PKG_NAME=nocache
PKG_VERSION=2020-06-06
PKG_SOURCE_VERSION=2b6ea1f6b46dabd08db6c6b8be78874b90ecfd22
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/Feh/nocache/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)
