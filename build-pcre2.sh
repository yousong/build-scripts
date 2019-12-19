#!/bin/bash -e
#
# Copyright 2016-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# TODO
#
#  - https://rust-leipzig.github.io/regex/2017/03/28/comparison-of-regex-engines/
#
PKG_NAME=pcre2
PKG_VERSION=10.34
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://ftp.pcre.org/pub/pcre/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d280b62ded13f9ccf2fac16ee5286366

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--enable-unicode
	--enable-jit
)
