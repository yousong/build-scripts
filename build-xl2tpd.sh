#!/bin/bash -e
#
# Copyright 2016-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# libpcap is for compiling pfc
#
# xl2tpd-control requires fmemopen which is not available in darwin stdio.h
#
PKG_NAME=xl2tpd
PKG_VERSION=1.3.11
PKG_SOURCE_VERSION=v1.3.11
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/xelerance/xl2tpd/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PLATFORM=linux
PKG_DEPENDS=ppp

. "$PWD/env.sh"

configure() {
	true
}

# NOTE: /usr/sbin/pppd is expected by default
#
#	PATH_USR_SBIN=$INSTALL_PREFIX/sbin/pppd
#	PATH_USR_SBIN=/usr/sbin/pppd
#
EXTRA_CFLAGS+=(
	-DPPPD="'\"$INSTALL_PREFIX/sbin/pppd\"'"
)

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)
