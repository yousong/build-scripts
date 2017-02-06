#!/bin/sh -e
#
# Copyright 2015-2017 (c) Yousong Zhou
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
PKG_VERSION=2017-02-03
PKG_SOURCE_VERSION=de3f14b643f09c799845073eaf3577a334d0726d
PKG_DEPENDS='json-c lua5.1'
PKG_CMAKE=1

. "$PWD/utils-lede.sh"
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
