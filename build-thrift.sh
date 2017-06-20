#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=thrift
PKG_VERSION=0.10.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://mirrors.tuna.tsinghua.edu.cn/apache/thrift/$PKG_VERSION/$PKG_SOURCE"
PKG_DEPENDS='boost1.61 python2'

. "$PWD/env.sh"

EXTRA_CFLAGS+=(-I"$INSTALL_PREFIX/boost/boost-1.61/include")
EXTRA_CPPFLAGS+=(-I"$INSTALL_PREFIX/boost/boost-1.61/include")
EXTRA_CXXFLAGS+=(-I"$INSTALL_PREFIX/boost/boost-1.61/include")

CONFIGURE_ARGS+=(
	--with-boost="$INSTALL_PREFIX/boost/boost-1.61"
	--with-cpp
)

MAKE_VARS+=(
	PY_PREFIX="$INSTALL_PREFIX"
)
