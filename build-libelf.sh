#!/bin/sh -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libelf
PKG_VERSION=0.8.13
PKG_SOURCE="libelf-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.mr511.de/software/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=4136d7b4c04df68b686570afa26988ac

. "$PWD/env.sh"

MAKE_VARS="$MAKE_VARS				\\
	instroot='$PKG_STAGING_DIR'	\\
"
