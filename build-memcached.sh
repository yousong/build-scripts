#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=memcached
PKG_VERSION=1.4.29
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.memcached.org/files/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=23720cac221811a24026c72f8fd8a803

. "$PWD/env.sh"
