#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# It provides libmagic for libguestfs
#
PKG_NAME=file
PKG_VERSION=5.36
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="ftp://ftp.astron.com/pub/$PKG_NAME/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=9af0eb3f5db4ae00fffc37f7b861575c

. "$PWD/env.sh"
