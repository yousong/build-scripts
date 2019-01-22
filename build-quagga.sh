#!/bin/bash -e
#
# Copyright 2016-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# configure requires gawk
#
PKG_NAME=quagga
PKG_VERSION=0.99.24.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://download.savannah.gnu.org/releases/quagga/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=7986bdc2fe6027d4c9216f7f5791e718

. "$PWD/env.sh"

CONFIGURE_ARGS+=(
	# requires makeinfo from texinfo
	--disable-doc
)
