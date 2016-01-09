#!/bin/sh -e
#
PKG_NAME=ncurses5
PKG_VERSION=5.9
PKG_SOURCE="ncurses-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/ncurses/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=8cb9c412e5f2d96bc6f459aa8c6282a1

. "$PWD/env.sh"
PKG_BUILD_DIR="$BASE_BUILD_DIR/ncurses-$PKG_VERSION"
PKG_STAGING_DIR="$BASE_DESTDIR/ncurses-$PKG_VERSION-install"

CONFIGURE_ARGS='			\
	--with-terminfo			\
	--enable-termcap		\
'
