#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=riscvemu
PKG_VERSION=2016-12-20.1
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://bellard.org/riscvemu/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=65c80333fbad113995bc2fd8f86d134c
PKG_DEPENDS=''

. "$PWD/env.sh"

configure() {
	true
}

staging() {
	true
}

install() {
	true
}
