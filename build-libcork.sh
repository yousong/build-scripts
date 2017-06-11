#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libcork
PKG_VERSION=0.15.0
PKG_SOURCE_VERSION=0.15.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/redjack/$PKG_NAME/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_CMAKE=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	echo "echo $PKG_VERSION" >version.sh
	patch -p0 <<"EOF"
--- CMakeLists.txt.orig	2016-02-20 23:53:12.901057746 +0800
+++ CMakeLists.txt	2016-02-20 23:53:24.809059606 +0800
@@ -10,7 +10,6 @@ cmake_minimum_required(VERSION 2.6)
 set(PROJECT_NAME libcork)
 set(RELEASE_DATE 2015-09-03)
 project(${PROJECT_NAME})
-enable_testing()
 
 set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
 find_package(ParseArguments)
@@ -122,5 +121,4 @@ set(THREADS_STATIC_LDFLAGS "${CMAKE_THRE
 add_subdirectory(include)
 add_subdirectory(share)
 add_subdirectory(src)
-add_subdirectory(tests)
 add_subdirectory(docs/old)
EOF
}
