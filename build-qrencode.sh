#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=qrencode
PKG_VERSION=4.0.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://fukuchi.org/works/qrencode/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=4946993cb59c7adf63e5ff5370635853
PKG_DEPENDS='libpng'

. "$PWD/env.sh"
