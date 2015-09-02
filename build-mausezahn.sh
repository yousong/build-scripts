#!/bin/sh -e
#
# Mausezahn depends on libnet, libpcap, libcli
#
#          sudo yum install -y libnet-devel libpcap-devel
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

. "$PWD/env.sh"

BUILD_DIR="$BASE_BUILD_DIR/mz-$VER"

prepare_from_tarball() {
    local ver="$VER"
    local fn="mz-$ver.tar.gz"
    local url="http://www.perihel.at/sec/mz/mz-$ver.tar.gz"

    if [ -x "$BUILD_DIR/CMakeLists.txt" ]; then
        __errmsg "$BUILD_DIR/CMakeLists.txt already exists, skip preparing."
        return 0
    else
        cd "$BASE_DL_DIR"
        wget -c -O "$fn" "$url"
        tar -C "$BASE_BUILD_DIR" -xzf "$fn"
    fi
}

build_mausezahn() {
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

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

	rm -rvf _t/
    mkdir -p _t/
    cd _t/
    # cmake should pick CFLAGS environment variable
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/.usr" ..
    make -j "1" VERBOSE=1
    make DESTDIR="$BASE_DESTDIR/_$PKGNAME-install" install
    cp "$BASE_DESTDIR/_$PKGNAME-install/$INSTALL_PREFIX" "$INSTALL_PREFIX"
}

prepare_from_tarball
build_mausezahn
