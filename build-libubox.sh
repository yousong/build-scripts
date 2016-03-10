#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# libubox on CentOS requires package json-c-devel
#
#	sudo yum install -y json-c-devel
#
# It's libjson0-dev on Debian Wheezy
#
PKG_NAME=libubox
PKG_VERSION=2016-03-06
PKG_SOURCE_VERSION=dfe446e2a981eaa83cb41df3840ca7c649dc7527
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}-${PKG_SOURCE_VERSION}.tar.gz"
PKG_SOURCE_URL="http://git.openwrt.org/?p=project/libubox.git;a=snapshot;h=$PKG_SOURCE_VERSION;sf=tgz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='json-c lua5.1'
PKG_CMAKE=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
--- lua/CMakeLists.txt.orig	2016-01-23 12:14:59.000000000 +0800
+++ lua/CMakeLists.txt	2016-01-23 12:22:35.000000000 +0800
@@ -15,7 +15,7 @@ IF(NOT LUA_CFLAGS)
 	ENDIF()
 ENDIF()
 
-ADD_DEFINITIONS(-Os -Wall -Werror --std=gnu99 -g3 -I.. ${LUA_CFLAGS})
+SET(CMAKE_C_FLAGS "-I.. ${LUA_CFLAGS} ${CMAKE_C_FLAGS} -Os -Wall -Werror --std=gnu99 -g3")
 LINK_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/..)
 
 IF(APPLE)
EOF
}
