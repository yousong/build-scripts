#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=s3fs-fuse
PKG_VERSION=1.91
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/s3fs-fuse/s3fs-fuse/archive/refs/tags/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=09cccbe6ea9416284dae1b78e8fe0598
PKG_DEPENDS='curl fuse libiconv libxml2 openssl'

PKG_SOURCE_UNTAR_FIXUP=1
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"
CONFIGURE_ARGS+=(
	--with-openssl
)
