#!/bin/sh -e
#
PKG_NAME=python2
PKG_VERSION="2.7.10"
PKG_SOURCE="Python-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://www.python.org/ftp/python/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="c685ef0b8e9f27b5e3db5db12b268ac6"

. "$PWD/env.sh"
PKG_BUILD_DIR="$BASE_BUILD_DIR/Python-$PKG_VERSION"
CONFIGURE_ARGS='				\
	--enable-unicode=ucs4		\
	--with-ensurepip=upgrade	\
'
