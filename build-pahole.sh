#!/bin/bash -e
#
# Copyright 2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=pahole
PKG_VERSION=1.19
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://git.kernel.org/pub/scm/devel/pahole/pahole.git/snapshot/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=6d1b36c327bb4041d462448dba358e31
PKG_CMAKE=1

. "$PWD/env.sh"

CMAKE_ARGS+=(
	#-D__LIB=lib
)
