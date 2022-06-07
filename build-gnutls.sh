#!/bin/bash -e
#
# Copyright 2016-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=gnutls
PKG_VERSION=3.6.14
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="ftp://ftp.gnutls.org/gcrypt/gnutls/v${PKG_VERSION%.*}/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=bf70632d420e421baff482247f01dbfe
PKG_DEPENDS='gmp libtasn1 nettle p11-kit unbound'

. "$PWD/env.sh"

# That key-file needs to be generated with
#
#		unbound-anchor -a "$INSTALL_PREFIX/etc/unbound/root.key"
#
# Enable local libopts in src/libopts because libopts25 available in Debian
# Wheezy lacks optionAlias() and will cause build failure
#
# Libunistring was not found. To use the included one, use --with-included-unistring
CONFIGURE_ARGS+=(
	--with-unbound-root-key-file="$INSTALL_PREFIX/etc/unbound/root.key"
	--with-included-unistring
	--enable-local-libopts
	--disable-guile
	--disable-silent-rules
)

configure_static_build() {
	CONFIGURE_ARGS+=(
		--enable-static
	)
}
