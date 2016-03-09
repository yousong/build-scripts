#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# flowtop requires libnetfilter-conntrack-dev
# curvetun requires nacl (networking and cryptography library)
#
PKG_NAME=netsniff-ng
PKG_VERSION=0.6.0
PKG_SOURCE=$PKG_NAME-$PKG_VERSION.tar.xz
PKG_SOURCE_URL="http://pub.netsniff-ng.org/netsniff-ng/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5bc28fc75e0e7fe41e2ec077fc527f8c
PKG_DEPENDS='ncurses libcli libnet libnl3 libpcap liburcu'
PKG_PLATFORM=linux

. "$PWD/env.sh"

# This is required for detection of libraries built by us, e.g. libcli etc.
CONFIGURE_VARS="$CONFIGURE_VARS				\\
	CC='gcc $EXTRA_CFLAGS $EXTRA_LDFLAGS'	\\
	LD='gcc $EXTRA_LDFLAGS'					\\
"

MAKE_VARS="$MAKE_VARS				\\
	PREFIX='$INSTALL_PREFIX'		\\
	ETCDIR='$INSTALL_PREFIX/etc'	\\
	Q=	\\
"
