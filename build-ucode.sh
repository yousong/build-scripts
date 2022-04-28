#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=ucode
PKG_VERSION=2022-04-07
PKG_SOURCE_VERSION=33f1e0b0926e973fb5ae445e9a995848762143bb
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/jow-/ucode/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='json-c'
PKG_CMAKE=1

. "$PWD/env.sh"

CMAKE_ARGS=(
	-DFS_SUPPORT=on
	-DMATH_SUPPORT=on
	-DRTNL_SUPPORT=off
	-DNL80211_SUPPORT=off
	-DRESOLV_SUPPORT=on
	-DSTRUCT_SUPPORT=on

	-DUBUS_SUPPORT=off
	-DUCI_SUPPORT=off
	-DULOOP_SUPPORT=off
)
