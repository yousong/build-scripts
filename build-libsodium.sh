#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libsodium
PKG_VERSION=1.0.13
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://download.libsodium.org/libsodium/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=f38aac160a4bd05f06f743863e54e499

. "$PWD/env.sh"
