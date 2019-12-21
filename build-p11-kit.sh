#!/bin/bash -e
#
# Copyright 2016-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=p11-kit
PKG_VERSION=0.23.18.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/p11-glue/p11-kit/releases/download/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=79480c3a2c905a74f86e885966148537
PKG_DEPENDS='libtasn1 libffi'

. "$PWD/env.sh"
