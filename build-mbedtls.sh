#!/bin/sh -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=mbedtls
PKG_VERSION=2.4.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-gpl.tgz"
PKG_SOURCE_URL="https://tls.mbed.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=31dc8692fd2a4ada0af6a74b7b06c507
PKG_CMAKE=1

PKG_BUILD_DIR_BASENAME="$PKG_NAME-$PKG_VERSION"
. "$PWD/env.sh"

#	-DENABLE_TESTING:Bool=OFF \\
#	-DENABLE_PROGRAMS:Bool=OFF \\
CMAKE_ARGS="$CMAKE_ARGS		\\
	-DUSE_SHARED_MBEDTLS_LIBRARY:Bool=ON \\
"
