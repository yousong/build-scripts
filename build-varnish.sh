#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=varnish
PKG_VERSION=6.1.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tgz"
PKG_SOURCE_URL="https://varnish-cache.org/_downloads/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=790eda3236308fdedb3953a7f0591e76
PKG_DEPENDS='ncurses pcre readline'

. "$PWD/env.sh"

# disable building docs
CONFIGURE_ARGS+=(
	--with-rst2man=:
	--with-sphinx-build=:
)
