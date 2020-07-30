#!/bin/bash -e
#
# Copyright 2016-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# unbound is required for compiling libdane contained within gnutls
#
# unbound-1.5.7 cannot compile with nettle-3.2 as the ssl library.
PKG_NAME=unbound
PKG_VERSION=1.11.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://unbound.net/downloads/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=528dcf9bb9aa693a14f9ad5bab417b85
PKG_DEPENDS='expat libevent openssl'

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--with-libevent="$INSTALL_PREFIX"
	--with-libexpat="$INSTALL_PREFIX"
	--with-ssl="$INSTALL_PREFIX"
)
