#!/bin/sh -e
#
# libpcap is for compiling pfc
#
PKG_NAME=xl2tpd
PKG_VERSION=devel-20151125
PKG_SOURCE_VERSION=e2065bf0fc22ba33001ad503c01bba01648024a8
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/xelerance/xl2tpd/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libpcap ppp'

. "$PWD/env.sh"

configure() {
	true
}

# NOTE: /usr/sbin/pppd is expected by default
#
#	PATH_USR_SBIN=$INSTALL_PREFIX/sbin/pppd
#	PATH_USR_SBIN=/usr/sbin/pppd
#
EXTRA_CFLAGS="$EXTRA_CFLAGS						\\
	-DPPPD='\\\\\\\"$INSTALL_PREFIX/sbin/pppd\\\\\\\"'	\\
"
MAKE_VARS="$MAKE_VARS					\\
	PREFIX='$INSTALL_PREFIX'			\\
"
