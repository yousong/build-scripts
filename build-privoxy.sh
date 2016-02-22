#!/bin/sh -e
#
PKG_NAME=privoxy
PKG_VERSION=3.0.23
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-stable-src.tar.gz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/ijbswa/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=bbe47d5ff1a54d9f9fc93a160532697f
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS=pcre

# privoxy does not bundle a configure script
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"
