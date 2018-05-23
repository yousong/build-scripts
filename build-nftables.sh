#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Requires on rhel
#
#	# covnert docbook into man and Texinfo
#	yum install -y docbook2X
#
# nftables requires at least linux kernel 3.13
#
# - https://netfilter.org/projects/nftables/index.html
#
PKG_NAME=nftables
PKG_VERSION=0.8.5
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="https://www.netfilter.org/projects/$PKG_NAME/files/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=706bdcbbe795961de61818ebad9c6a4d
PKG_DEPENDS='libnftnl'
PKG_PLATFORM=linux

. "$PWD/env.sh"
