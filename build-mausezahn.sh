#!/bin/sh -e
#
# Mausezahn depends on libnet, libpcap, libcli
#
#          sudo yum install -y libnet-devel libpcap-devel
#          sudo apt-get install -y libnet-dev libpcap-dev
#
# mausezahn requires header file netpacket/packet.h which is not available in
# Mac OS X
#
PKG_NAME=mausezahn
PKG_VERSION="0.40"
PKG_SOURCE="mz-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://www.perihel.at/sec/mz/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="d3d959c92cbf3d81224f5b2f8409e9d8"
PKG_CMAKE=1
PKG_DEPENDS='libcli libnet'
PKG_PLATFORM=linux

. "$PWD/env.sh"
PKG_BUILD_DIR="$BASE_BUILD_DIR/mz-$PKG_VERSION"

do_patch() {
	cd "$PKG_BUILD_DIR"

	patch <<"EOF"
--- CMakeLists.txt.orig	2015-08-31 17:53:28.525000435 +0800
+++ CMakeLists.txt	2015-08-31 17:55:10.231000417 +0800
@@ -5,7 +5,7 @@ if(COMMAND cmake_policy)
 	cmake_policy(SET CMP0003 NEW)
 endif(COMMAND cmake_policy)
 
-SET(CMAKE_C_FLAGS "-Wall -pipe -fexceptions -fstack-protector --param=ssp-buffer-size=4 -fasynchronous-unwind-tables")
+SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -pipe -fexceptions -fstack-protector --param=ssp-buffer-size=4 -fasynchronous-unwind-tables")
 
 ADD_CUSTOM_TARGET(uninstall
EOF
}
