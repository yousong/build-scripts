#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=jemalloc
PKG_VERSION=4.2.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://github.com/jemalloc/jemalloc/releases/download/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=094b0a7b8c77c464d0dc8f0643fd3901

. "$PWD/env.sh"
