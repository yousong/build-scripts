#!/bin/bash -e
#
# Copyright 2021 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Homepage: http://darkk.net.ru/redsocks/
#
# See redsocks.conf.example in the source code
#
# 	socksip=127.0.0.1
# 	socksport=7001
# 	cp redsocks.conf{.example,}
# 	sed -i -e 's/log_debug = .*$/log_debug = on;/' redsocks.conf
# 	sed -i -e '/^redsocks {$/,/^}$/s/^\([\t ]\+ip\) = .*$/\1 = '"$socksip"';/' redsocks.conf
# 	sed -i -e '/^redsocks {$/,/^}$/s/^\([\t ]\+port\) = .*$/\1 = '"$socksport"';/' redsocks.conf
# 	redsocks -c redsocks.conf
#
# 	port="$(sed -n '/^redsocks {$/,/^}$/p' redsocks.conf \
# 		| grep -E '^\s*local_port = ' \
# 		| grep -oE '[0-9]+')"
# 	iptables -t nat -A OUTPUT -p tcp -m owner --uid-owner $USER -j REDIRECT --to-ports 12345
# 	iptables -t nat -A OUTPUT -d github.com -p tcp -j REDIRECT --to-ports 12345
#
PKG_NAME=redsocks
PKG_VERSION=2019-07-16
PKG_SOURCE_VERSION=19b822e345f6a291f6cff6b168f1cfdfeeb2cd7d
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/darkk/redsocks/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=0e765f742994d57b3bdb5d8217873760
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS=libevent

. "$PWD/env.sh"

configure() {
	true
}

staging() {
	local bindir="$PKG_STAGING_DIR$INSTALL_PREFIX/bin"

	mkdir -p "$bindir"
	cp "$PKG_BUILD_DIR/redsocks" "$bindir/redsocks"
}
