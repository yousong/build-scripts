#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=strace
PKG_VERSION=4.12
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/strace/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=efb8611fc332e71ec419c53f59faa93e
PKG_DEPENDS=libunwind

. "$PWD/env.sh"

CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--with-libunwind=yes		\\
"
