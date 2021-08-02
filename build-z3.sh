#!/bin/bash -e
#
# Copyright 2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=z3
PKG_VERSION=4.8.12
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/Z3Prover/z3/archive/refs/tags/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=73fd07d094685039b03aed9e38040d13
PKG_SOURCE_UNTAR_FIXUP=1
PKG_CMAKE=1

. "$PWD/env.sh"
