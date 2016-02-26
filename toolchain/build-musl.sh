#!/bin/sh -e

PKG_NAME=musl
PKG_VERSION=1.1.14
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://www.musl-libc.org/releases/musl-1.1.14.tar.gz"
PKG_SOURCE_MD5SUM=d529ce4a2f7f79d8c3fd4b8329417b57

. "$PWD/env.sh"

CONFIGURE_ARGS="$CONFIGURE_ARGS			\\
	--syslibdir='$INSTALL_PREFIX/lib'	\\
"
