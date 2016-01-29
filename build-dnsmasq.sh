#!/bin/sh -e
#
# @libnettle is required for DNSSEC support
#
PKG_NAME=dnsmasq
PKG_VERSION=2.75
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://www.thekelleys.org.uk/dnsmasq/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=887236f1ddde6eb57cdb9d01916c9f72

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS="							\\
	PREFIX='$INSTALL_PREFIX'		\\
"
