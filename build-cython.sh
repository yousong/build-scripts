#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Cython FAQ, https://github.com/cython/cython/wiki/FAQ
#
PKG_NAME=Cython
PKG_VERSION=0.23.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://cython.org/release/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=157df1f69bcec6b56fd97e0f2e057f6e
PKG_PYTHON_VERION="2 3"

. "$PWD/env.sh"
. "$PWD/utils-python.sh"
