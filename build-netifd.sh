#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
PKG_NAME=netifd
PKG_VERSION=2016-03-07
PKG_SOURCE_VERSION=bd1ee3efb46ae013d81b1aec51668e7595274e69
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-${PKG_SOURCE_VERSION}.tar.gz"
PKG_SOURCE_URL="http://git.openwrt.org/?p=project/netifd.git;a=snapshot;h=$PKG_SOURCE_VERSION;sf=tgz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libnl3 libubox lua5.1 ubus uci'
PKG_CMAKE=1

. "$PWD/env.sh"
