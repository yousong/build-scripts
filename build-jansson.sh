#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=jansson
PKG_VERSION=2.12
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://www.digip.org/jansson/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=0ed1f3a924604aae68067c214b0010ef

. "$PWD/env.sh"
