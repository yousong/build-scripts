#!/bin/bash -e
#
# Copyright 2016-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=pcre
PKG_VERSION=8.43
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://ftp.pcre.org/pub/pcre/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=636222e79e392c3d95dcc545f24f98c4

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--enable-unicode-properties
	--enable-jit
)
