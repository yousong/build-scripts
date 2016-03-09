#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# This package does not install anything
#
# Code resides in $PKG_BUILD_DIR/UnixBench.  Run the test with
#
#		./Run | tee r.txt
#
# Read UnixBench/USAGE for usage details
#
PKG_NAME=byte-unixbench
PKG_VERSION=5.1.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/kdlucas/byte-unixbench/archive/v$PKG_VERSION.tar.gz"

. "$PWD/env.sh"
MAKE_ARGS="			\\
	-C UnixBench	\\
"

configure() {
	true
}

staging() {
	true
}

install() {
	true
}
