#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libnetfilter_cttimeout
PKG_VERSION=1.0.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://www.netfilter.org/projects/$PKG_NAME/files/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=7697437fc9ebb6f6b83df56a633db7f9
PKG_DEPENDS='libmnl'
PKG_PLATFORM=linux

. "$PWD/env.sh"
