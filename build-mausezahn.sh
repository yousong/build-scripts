#!/bin/sh -e
#
# Mausezahn depends on libnet, libpcap, libcli
#
#          sudo yum install -y libnet-devel libpcap-devel
#          sudo apt-get install -y libnet-dev libpcap-dev
#
# The built command mz needs to be run with root privileges.  Simply doing
# "sudo mz" is not enough as the environment variable LD_LIBRARY_PATH will be
# reset and dependent libraries cannot be found.  The solution can be one of
# the following if any of them work for the then current situation.
#
#  - Setup an alias and use mz as usual
#
#			alias mz="sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH $(which mz)"
#
#  - Use "sudo -E mz" if system security policy permits
#  - Use "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH mz"
#

PKGNAME=mausezahn
VER="0.40"

PKG_NAME=mausezahn
PKG_VERSION="0.40"
PKG_SOURCE="mz-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://www.perihel.at/sec/mz/$PKG_SOURCE"
PKG_SOURCE_MD5SUM="d3d959c92cbf3d81224f5b2f8409e9d8"

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
+SET(CMAKE_C_FLAGS "-Wall -pipe -fexceptions -fstack-protector --param=ssp-buffer-size=4 -fasynchronous-unwind-tables -I$ENV{HOME}/.usr/include -L$ENV{HOME}/.usr/lib")
 
 ADD_CUSTOM_TARGET(uninstall
EOF
}

MAKE_VARS="VERBOSE=1"

build_configure() {
    cd "$PKG_BUILD_DIR"
    # cmake should pick CFLAGS environment variable
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
}

main
