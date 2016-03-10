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

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- CMakeLists.txt.orig	2016-03-10 18:08:38.488381413 +0800
+++ CMakeLists.txt	2016-03-10 18:11:47.088445183 +0800
@@ -22,8 +22,10 @@ SET(LIBS
 	ubox ubus uci json-c blobmsg_json)
 
 IF (NOT DEFINED LIBNL_LIBS)
-  FIND_LIBRARY(libnl NAMES libnl-3 libnl nl-3 nl)
-  SET(LIBNL_LIBS ${libnl})
+	INCLUDE(FindPkgConfig)
+	PKG_SEARCH_MODULE(libnl libnl-3.0 libnl-3 nl-3 libnl nl)
+	SET(LIBNL_LIBS ${libnl_LDFLAGS})
+	ADD_DEFINITIONS(${libnl_CFLAGS})
 ENDIF()
 
 IF("${CMAKE_SYSTEM_NAME}" MATCHES "Linux" AND NOT DUMMY_MODE)
EOF
}
