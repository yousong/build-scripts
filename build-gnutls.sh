#!/bin/sh -e

PKG_NAME=gnutls
PKG_VERSION=3.4.9
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="ftp://ftp.gnutls.org/gcrypt/gnutls/v${PKG_VERSION%.*}/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1b3b6d55d0e2b6d01a54f53129f1da9b
PKG_DEPENDS='gmp libtasn1 nettle p11-kit unbound'

. "$PWD/env.sh"

# That key-file needs to be generated with
#
#		unbound-anchor -a "$INSTALL_PREFIX/etc/unbound/root.key"
#
CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--with-unbound-root-key-file='$INSTALL_PREFIX/etc/unbound/root.key'	\\
	--disable-guile				\\
"
