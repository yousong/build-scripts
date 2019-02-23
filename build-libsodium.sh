#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libsodium
PKG_VERSION=1.0.17
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://download.libsodium.org/libsodium/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=0f71e2680187a1558b5461e6879342c5

. "$PWD/env.sh"
