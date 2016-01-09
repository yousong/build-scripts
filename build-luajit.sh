#!/bin/sh -e
#
PKG_NAME=LuaJIT
PKG_VERSION=2.0.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://luajit.org/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=dd9c38307f2223a504cbfb96e477eca0

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS="PREFIX=$INSTALL_PREFIX"
