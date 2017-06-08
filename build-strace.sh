#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=strace
PKG_VERSION=4.17
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/strace/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=8d7eb10eba68bad83a269197e634b626
PKG_DEPENDS=libunwind

. "$PWD/env.sh"

# 4.12 has a bug fixed by "7c0e887": configure.ac: fix checks for btrfs
# specific structures
#
# we cannot use PKG_AUTOCONF_FIXUP because the AC_INIT refers to a utility
# called ./git-version-gen which is not packaged in the relesae tarball
CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--with-libunwind=yes		\\
"
