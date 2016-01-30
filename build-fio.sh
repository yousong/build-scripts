#!/bin/sh -e
#
PKG_NAME=fio
PKG_VERSION=2.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://brick.kernel.dk/snaps/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=edfd730054b402235f7cf0f61d5ce883
PKG_DEPENDS=zlib

. "$PWD/env.sh"

if os_is_linux; then
	PKG_DEPENDS="$PKG_DEPENDS libaio"
fi

CONFIGURE_ARGS="$CONFIGURE_ARGS							\\
	--extra-cflags='$EXTRA_CFLAGS $EXTRA_LDFLAGS'		\\
"

MAKE_VARS="												\\
	V=s													\\
	mandir='$INSTALL_PREFIX/share/man'					\\
	sharedir='$INSTALL_PREFIX/share/fio'				\\
"
