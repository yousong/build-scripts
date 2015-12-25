#!/bin/sh -e
#
PKG_NAME=binutils
PKG_VERSION=2.25.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/binutils/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=ac493a78de4fee895961d025b7905be4

. "$PWD/env.sh"

# --with-sysroot is needed for quashing the error message "this linker was not
# configured to use sysroots"
CONFIGURE_ARGS="							\\
	--with-sysroot='$INSTALL_PREFIX'		\\
"
