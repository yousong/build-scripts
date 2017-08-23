#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libnetfilter_conntrack
PKG_VERSION=1.0.6
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://www.netfilter.org/projects/$PKG_NAME/files/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=7139c5f408dd9606ffecfd5dcda8175b
PKG_DEPENDS='libmnl libnfnetlink'
PKG_PLATFORM=linux

. "$PWD/env.sh"
