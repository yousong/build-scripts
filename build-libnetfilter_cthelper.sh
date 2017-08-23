#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libnetfilter_cthelper
PKG_VERSION=1.0.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://www.netfilter.org/projects/$PKG_NAME/files/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b2efab1a3a198a5add448960ba011acd
PKG_DEPENDS='libmnl'
PKG_PLATFORM=linux

. "$PWD/env.sh"
