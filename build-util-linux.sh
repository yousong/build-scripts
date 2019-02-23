#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# It provides libblkid.so and libuuid.so
#
PKG_NAME=util-linux
PKG_VERSION=2.33.1
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://www.kernel.org/pub/linux/utils/util-linux/v2.33/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=6fcfea2043b5ac188fd3eed56aeb5d90
PKG_DEPENDS=''
PKG_PLATFORM=linux

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--disable-makeinstall-chown
	--disable-makeinstall-setuid
)
