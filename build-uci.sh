#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
PKG_NAME=uci
PKG_VERSION=2016-03-07
PKG_SOURCE_VERSION=18c13247f9e0bfad1effc0445bcda436d03789c5
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-${PKG_SOURCE_VERSION}.tar.gz"
PKG_SOURCE_URL="http://git.openwrt.org/?p=project/uci.git;a=snapshot;h=$PKG_SOURCE_VERSION;sf=tgz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libubox lua5.1'
PKG_CMAKE=1

. "$PWD/env.sh"
