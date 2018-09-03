#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=protobuf-c
PKG_VERSION="1.3.1"
PKG_SOURCE="protobuf-c-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/protobuf-c/protobuf-c/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=
PKG_DEPENDS="protobuf"

. "$PWD/env.sh"
