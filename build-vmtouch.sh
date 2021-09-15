#!/bin/bash -e
#
# Copyright 2021 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Homepage: https://hoytech.com/vmtouch/
#
# vmtouch and cachestats(nocache) uses mincore for inspecting resident pages
#
# 	vmtouch -e file		evict
# 	vmtouch -t file		touch
# 	vmtouch    file		view
#
PKG_NAME=vmtouch
PKG_VERSION=2021-08-15
PKG_SOURCE_VERSION=8f6898e3c027f445962e223ca7a7b33d40395fc6
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/hoytech/vmtouch/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)
