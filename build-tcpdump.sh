#!/bin/sh -e
#
# Copyright 2016-2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=tcpdump
PKG_VERSION=4.9.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.tcpdump.org/release/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=2b83364eef53b63ca3181b4eb56dab0c
PKG_DEPENDS='libpcap openssl'

. "$PWD/env.sh"
if os_is_linux; then
	PKG_DEPENDS="libnl3 $PKG_DEPENDS"
fi

CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--with-system-libpcap		\\
"
