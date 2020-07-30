#!/bin/bash -e
#
# Copyright 2015-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# This is mainly for tmux-2.x on CentOS 6.6
#
PKG_NAME=libevent
PKG_VERSION=2.1.12
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-stable.tar.gz"
PKG_SOURCE_URL="https://github.com/libevent/libevent/releases/download/release-$PKG_VERSION-stable/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b5333f021f880fe76490d8a799cd79f4
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS=openssl

. "$PWD/env.sh"
