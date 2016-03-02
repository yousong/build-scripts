#!/bin/sh -e
#
# unbound is required for compiling libdane contained within gnutls
#
# unbound-1.5.7 cannot compile with nettle-3.2 as the ssl library.
PKG_NAME=unbound
PKG_VERSION=1.5.7
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://unbound.net/downloads/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=a1253cbbb339dbca03404dcc58365d71
PKG_DEPENDS=openssl

. "$PWD/env.sh"
