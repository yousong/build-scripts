#!/bin/bash -e
#
# Copyright 2016-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=uci
PKG_VERSION=2019-09-01
PKG_SOURCE_VERSION=415f9e48436d29f612348f58f546b3ad8d74ac38
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-${PKG_SOURCE_VERSION}.tar.gz"
PKG_SOURCE_URL="http://git.openwrt.org/?p=project/uci.git;a=snapshot;h=$PKG_SOURCE_VERSION;sf=tgz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libubox lua5.1'
PKG_CMAKE=1

. "$PWD/env.sh"
