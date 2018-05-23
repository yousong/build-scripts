#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libnftnl
PKG_VERSION=1.1.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://www.netfilter.org/projects/$PKG_NAME/files/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=ffe4f2b3724994b8e73c985d0cb1e407
PKG_DEPENDS='libmnl'
PKG_PLATFORM=linux

. "$PWD/env.sh"
