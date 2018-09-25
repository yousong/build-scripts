#!/bin/bash -e
#
# Copyright 2016-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=keepalived
PKG_VERSION=2.0.7
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.keepalived.org/software/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5204f541c75f4f68339809f0761693c5
PKG_DEPENDS='libnl3 net-snmp openssl'
PKG_PLATFORM=linux

. "$PWD/env.sh"

# clear up -I$INSTALL_PREFIX/include to avoid libipvs to include
# netlink/netlink.h from libnl1
EXTRA_CFLAGS=()
CONFIGURE_ARGS+=(
	--enable-snmp
	--enable-sha1
	--without-init	# do not install any types of initscripts
)
