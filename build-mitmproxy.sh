#!/bin/bash -e
#
# Copyright 2018-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=mitmproxy
PKG_VERSION=4.0.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-linux.tar.gz"
PKG_SOURCE_URL="https://snapshots.mitmproxy.org/$PKG_VERSION/mitmproxy-$PKG_VERSION-linux.tar.gz"
PKG_SOURCE_MD5SUM=bee8543567ab572c50eb7188af8aad66
PKG_DEPENDS=linux		# it also has binaries for osx and windows

. "$PWD/env.sh"
STRIP=()

prepare() {
	true
}

configure() {
	true
}

compile() {
	true
}

staging() {
	local bindir="$PKG_STAGING_DIR$INSTALL_PREFIX/bin"
	mkdir -p "$bindir"
	unpack "$BASE_DL_DIR/$PKG_SOURCE" "$bindir"
}

install_post() {
	cat >&2 <<EOF
EOF
}
