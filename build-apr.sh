#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# APR for Apache Portable Runtime
#
PKG_NAME=apr
PKG_VERSION=1.5.2
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://www.us.apache.org/dist//apr/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=4e9769f3349fe11fc0a5e1b224c236aa

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--enable-layout=GNU
)
