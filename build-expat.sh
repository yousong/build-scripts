#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=expat
PKG_VERSION=2.2.5
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://github.com/libexpat/libexpat/releases/download/R_${PKG_VERSION//./_}/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=789e297f547980fc9ecc036f9a070d49

. "$PWD/env.sh"
