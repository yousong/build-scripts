#!/bin/sh -e
#
PKG_NAME=db
PKG_VERSION=5.3.28
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://download.oracle.com/berkeley-db/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b99454564d5b4479750567031d66fe24

. "$PWD/env.sh"

CONFIGURE_PATH="$PKG_BUILD_DIR/build_unix"
CONFIGURE_CMD="../dist/configure"
# --enable-dbm, is for python module dbm
CONFIGURE_ARGS='			\
	--disable-tcl			\
	--disable-java			\
	--enable-compat185		\
	--enable-dbm			\
'

MAKE_ARGS="							\\
	-C '$PKG_BUILD_DIR/build_unix'	\\
"
MAKE_VARS="												\\
	docdir='$INSTALL_PREFIX/share/db-$PKG_VERSION/docs'	\\
"
