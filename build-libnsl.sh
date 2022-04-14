#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libnsl
PKG_VERSION="2.0.0"
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://github.com/thkukuk/libnsl/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1e8c0615071ea13202452304de1eaab9
PKG_DEPENDS='libtirpc'

. "$PWD/env.sh"
