#!/bin/bash -e
#
# Copyright 2016-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# TODO
#
#  - https://rust-leipzig.github.io/regex/2017/03/28/comparison-of-regex-engines/
#
PKG_NAME=pcre2
PKG_VERSION=10.21
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=e79460519f916e3fcb204e59714bfd4a

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	--enable-unicode
	--enable-jit
)
