#!/bin/bash -e
#
# Copyright 2015-2019 (c) Yousong Zhou
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
PKG_VERSION=2019-02-27
PKG_SOURCE_VERSION=eeef7b50a06bc3c3218d560b4b513b4e7b19127f
PKG_DEPENDS='json-c lua5.1'
PKG_CMAKE=1

. "$PWD/utils-openwrt.sh"
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
