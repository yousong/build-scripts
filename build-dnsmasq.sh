#!/bin/bash -e
#
# Copyright 2016-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# @libnettle is required for DNSSEC support
#
PKG_NAME=dnsmasq
PKG_VERSION=2.80
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://www.thekelleys.org.uk/dnsmasq/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=e040e72e6f377a784493c36f9e788502

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)
