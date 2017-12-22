#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=spark
PKG_VERSION=2.2.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-bin-without-hadoop.tgz"
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-bin-hadoop2.7.tgz"
PKG_SOURCE_URL="https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1a015f7e56500926bbdfab8350a8cf80
PKG_SOURCE_MD5SUM=c0081f6076070f0a6c6a607c71ac7e95
PKG_DEPENDS=linux
#PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"
STRIP=()

configure() {
	true
}

compile() {
	true
}

staging() {
	local bindir="$PKG_STAGING_DIR$INSTALL_PREFIX/bin"
	mkdir -p "$bindir"
	cpdir "$PKG_BUILD_DIR" "$bindir"
}

install_post() {
	cat >&2 <<EOF
EOF
}
