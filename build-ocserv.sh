#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Additional requirements
#
# 	libhttp-parser, builtin available from nginx
# 	libpam
# 	ronn, ruby-conn, manpages
#
PKG_NAME=ocserv
PKG_VERSION=0.12.1
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="ftp://ftp.infradead.org/pub/ocserv/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=050b0eebf911b595cc56ee104e2dbade
PKG_DEPENDS='gnutls libnl3 libpcl libprotobuf-c lz4 pcl readline talloc zlib'

. "$PWD/env.sh"

# libreadline requires ncursesw
EXTRA_LDFLAGS+=(
	-lncursesw
)
