#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=ppp
PKG_VERSION=2.4.7
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://download.samba.org/pub/ppp/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=78818f40e6d33a1d1de68a1551f6595a
PKG_DEPENDS=libpcap
PKG_PLATFORM=linux

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--sysconfdir="$INSTALL_PREFIX/etc"
)
MAKE_VARS+=(
	COPTS="${EXTRA_CFLAGS[*]} -D_ROOT_PATH='\"$INSTALL_PREFIX\"'"
	INSTROOT="$PKG_STAGING_DIR$INSTALL_PREFIX"
	DESTDIR="$PKG_STAGING_DIR$INSTALL_PREFIX"
)
