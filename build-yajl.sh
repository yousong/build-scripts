#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=yajl
PKG_VERSION=2.1.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/lloyd/yajl/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=6887e0ed7479d2549761a4d284d3ecb0
PKG_SOURCE_UNTAR_FIXUP=1
PKG_CMAKE=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- src/CMakeLists.txt.orig	2019-10-12 03:06:27.173272666 +0000
+++ src/CMakeLists.txt	2019-10-12 03:18:23.702121206 +0000
@@ -35,9 +35,11 @@ SET (shareDir ${CMAKE_CURRENT_BINARY_DIR
 # set the output path for libraries
 SET(LIBRARY_OUTPUT_PATH ${libDir})
 
-ADD_LIBRARY(yajl_s STATIC ${SRCS} ${HDRS} ${PUB_HDRS})
+ADD_LIBRARY(yajl_object OBJECT ${SRCS} ${HDRS} ${PUB_HDRS})
+set_property(TARGET yajl_object PROPERTY POSITION_INDEPENDENT_CODE 1)
 
-ADD_LIBRARY(yajl SHARED ${SRCS} ${HDRS} ${PUB_HDRS})
+ADD_LIBRARY(yajl_s STATIC $<TARGET_OBJECTS:yajl_object>)
+ADD_LIBRARY(yajl SHARED $<TARGET_OBJECTS:yajl_object>)
 
 #### setup shared library version number
 SET_TARGET_PROPERTIES(yajl PROPERTIES
EOF
}
