#!/bin/bash -e
#
# Copyright 2016-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=keepalived
PKG_VERSION=2.0.19
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.keepalived.org/software/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=df670e0904d4e48e72ccc8409ad9c6de
PKG_DEPENDS='libnl3 net-snmp openssl'
PKG_PLATFORM=linux

. "$PWD/env.sh"

# clear up -I$INSTALL_PREFIX/include to avoid libipvs to include
# netlink/netlink.h from libnl1
EXTRA_CFLAGS=()

CONFIGURE_ARGS+=(
	--enable-sha1
	--without-init	# do not install any types of initscripts
	--disable-silent-rules
)

configure_static_build() {
	configure_static_build_default

	# requires static libraries from perl
	CONFIGURE_ARGS+=(
		--disable-snmp
	)
	# configure.ac does not know about this
	MAKE_VARS+=(
		LIBS="-lcrypto -ldl"
	)
}

configure_static_build_off() {
	CONFIGURE_ARGS+=(
		--enable-snmp
	)
}
