#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=x265
PKG_VERSION=2.0
PKG_SOURCE="${PKG_NAME}_${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://bitbucket.org/multicoreware/x265/downloads/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a4f16c0f054f002d6d8c9c6f7fb03026
PKG_CMAKE=1
PKG_CMAKE_BUILD_SUBDIR=_build
PKG_CMAKE_SOURCE_SUBDIR=source

. "$PWD/env.sh"
