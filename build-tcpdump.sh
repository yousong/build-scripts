#!/bin/bash -e
#
# Copyright 2016-2021 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# tcpdump 4.99 can fail with "[Invalid header: len(100) < caplen(116)]"
# when reading dumps written by old versions of the program (e.g.  4.9.2).
# The check was introduced in tcpdump commit 9e6ba479 ("Add sanity checks on
# packet header (packet length / capture length)")
#
# - https://github.com/the-tcpdump-group/tcpdump/commit/9e6ba479d8cee861a396cae59d7cf91bd3a5a563
#
PKG_NAME=tcpdump
PKG_VERSION=4.9.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.tcpdump.org/release/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a4ead41d371f91aa0a2287f589958bae
PKG_DEPENDS='libpcap openssl'

. "$PWD/env.sh"
if os_is_linux; then
	PKG_DEPENDS="libnl3 $PKG_DEPENDS"
fi

CONFIGURE_ARGS+=(
	--with-system-libpcap
)
