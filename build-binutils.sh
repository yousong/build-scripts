#!/bin/sh -e
#
# GNU ar provided by binutils is different from BSD ld (/usr/bin/ar) present in
# Mac OS X.  From the output of `/usr/bin/ar -vt lib/libncursesw.a' where
# `libncursesw.a' was generated with GNU ar, Clang can only work with those
# made by /usr/bin/ar
#
# - http://stackoverflow.com/questions/22107616/static-library-built-for-archive-which-is-not-the-architecture-being-linked-x86
#
PKG_NAME=binutils
PKG_VERSION=2.25.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/binutils/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=ac493a78de4fee895961d025b7905be4
PKG_PLATFORM=linux

. "$PWD/env.sh"

# --with-sysroot is needed for quashing the error message "this linker was not
# configured to use sysroots"
CONFIGURE_ARGS="							\\
	--with-sysroot='$INSTALL_PREFIX'		\\
"
