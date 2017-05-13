#!/bin/sh -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# A tutorial: https://stedolan.github.io/jq/tutorial/
#
#	.
#	.[] | { message: .commit.message }
#	[ .[] | { message: .commit.message } ]
#	[ .[] | { message: .commit.message, [ parents: .parents[].html_url ] } ]
#
PKG_NAME=jq
PKG_VERSION=1.5
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/stedolan/jq/releases/download/jq-$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=0933532b086bd8b6a41c1b162b1731f9

. "$PWD/env.sh"

# --disable-maintainer-mode, use pre-generated lexer and parser
CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--disable-maintainer-mode	\\
"
