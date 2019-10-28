#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=fstools
PKG_VERSION=2019-10-27
PKG_SOURCE_VERSION=eda8b3fbcc0eb0752c4d02276950c3b977eac259
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-${PKG_SOURCE_VERSION}.tar.gz"
PKG_SOURCE_URL="http://git.openwrt.org/?p=project/$PKG_NAME.git;a=snapshot;h=$PKG_SOURCE_VERSION;sf=tgz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libubox ubus uci'
PKG_CMAKE=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p1 <<"EOF"
--- a/CMakeLists.txt.orig	2019-10-25 08:40:29.924130260 +0000
+++ b/CMakeLists.txt	2019-10-25 08:40:33.199113017 +0000
@@ -1,7 +1,7 @@
 cmake_minimum_required(VERSION 2.6)
 
 PROJECT(fs-tools C)
-ADD_DEFINITIONS(-Os -ggdb -Wall -Werror --std=gnu99 -Wmissing-declarations -Wno-format-truncation)
+ADD_DEFINITIONS(-Os -ggdb -Wall -Werror --std=gnu99 -Wmissing-declarations -Wno-self-assign)
 
 SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
 
EOF

}
