#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=ucode
PKG_VERSION=2022-02-09
PKG_SOURCE_VERSION=a317c17f5ddfc3f749d349de01eeea5cad3eb162
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/jow-/ucode/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='json-c'
PKG_CMAKE=1

. "$PWD/env.sh"

CMAKE_ARGS=(
	-DFS_SUPPORT=on
	-DMATH_SUPPORT=on
	-DUBUS_SUPPORT=off
	-DUCI_SUPPORT=off
	-DRTNL_SUPPORT=off
	-DNL80211_SUPPORT=off
	-DRESOLV_SUPPORT=on
	-DSTRUCT_SUPPORT=on
)
