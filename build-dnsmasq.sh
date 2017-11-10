#!/bin/bash -e
#
# Copyright 2016-2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# @libnettle is required for DNSSEC support
#
PKG_NAME=dnsmasq
PKG_VERSION=2.78
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://www.thekelleys.org.uk/dnsmasq/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=6d0241b72c79d2b510776ccc4ed69ca4

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)
