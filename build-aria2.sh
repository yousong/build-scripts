#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Build dependencies, https://aria2.github.io/manual/en/html/README.html#dependency
#
# Quickstart
#
#	aria2c -i uris.txt
#	aria2c -x2 http://a/f.iso	# two connections per host
#	aria2c http://a/f.iso ftp://b/f.iso	# same file from two sources
#
#	aria2c -h#help	# help on help
#	aria2c -h#http	# help on http
#	aria2c -h#advanced
#
PKG_NAME=aria2
PKG_VERSION=1.33.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://github.com/aria2/aria2/releases/download/release-$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=46979c7291403a785e936d0ca244efea
PKG_DEPENDS='c-area gmp gnutls libxml2 nettle sqlite zlib'

. "$PWD/env.sh"
#aria2 requires c++11-capable compiler
#env_init_gnu_toolchain

CONFIGURE_ARGS+=(
	--disable-silent-rules
)
