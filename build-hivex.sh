#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=hivex
PKG_VERSION=1.3.18
PKG_SOURCE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://download.libguestfs.org/${PKG_NAME}/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=8468074cdc6e870e8f6a2c831ce22a0d
PKG_DEPENDS='libiconv libxml2 xz zlib'

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--disable-nls
	--disable-ocaml
	--disable-perl
	--disable-python
	--disable-ruby
)
