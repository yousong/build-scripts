#!/bin/bash -e
#
# Copyright 2016-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libpcap
PKG_VERSION=1.9.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.tcpdump.org/release/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=21af603d9a591c7d96a6457021d84e6c
PKG_CMAKE=1

. "$PWD/env.sh"
if os_is_linux; then
	PKG_DEPENDS=libnl3
fi

# we do not want to depend on system's libdbus without setting RPATH.  This is
# important for other packages like bmv2 depending on us yet failed to run
# conftest because of dynamic linking issues
CONFIGURE_ARGS+=(
	--disable-dbus
)
