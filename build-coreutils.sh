#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=coreutils
PKG_VERSION=8.31
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://ftp.gnu.org/gnu/coreutils/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=0009a224d8e288e8ec406ef0161f9293
PKG_DEPENDS='gmp libcap libiconv'

. "$PWD/env.sh"
