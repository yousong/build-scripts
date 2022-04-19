#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=axel
PKG_VERSION=2.17.11
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://github.com/axel-download-accelerator/axel/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=3ca473bfcd5c60499bfcd695c1bf3c15
PKG_DEPENDS='openssl'

. "$PWD/env.sh"
