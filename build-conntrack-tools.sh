#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=conntrack-tools
PKG_VERSION=1.4.4
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_URL="https://www.netfilter.org/projects/$PKG_NAME/files/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=acd9e0b27cf16ae3092ba900e4d7560e
PKG_DEPENDS='libmnl libnetfilter_conntrack libnetfilter_cthelper libnetfilter_cttimeout libnetfilter_queue libnfnetlink'
PKG_PLATFORM=linux

. "$PWD/env.sh"
