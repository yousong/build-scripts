#!/bin/bash -e
#
# Copyright 2019-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# It provides libblkid.so and libuuid.so
#
PKG_NAME=util-linux
PKG_VERSION=2.36.1
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://www.kernel.org/pub/linux/utils/util-linux/v2.36/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b0b702979d47043d9c4d8ba93be21e20
PKG_DEPENDS=''
PKG_PLATFORM=linux

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--disable-makeinstall-chown
	--disable-makeinstall-setuid
	--with-bashcompletiondir="$INSTALL_PREFIX/share/bash-completion"
)
