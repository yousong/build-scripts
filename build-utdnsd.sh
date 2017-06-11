#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=utdnsd
PKG_VERSION=2016-03-09.2
PKG_SOURCE_VERSION=135c868c8ed203a5d07aca22bc2e0a3be4349f49
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/yousong/utdnsd/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_CMAKE=1
PKG_DEPENDS='libubox'

. "$PWD/env.sh"
