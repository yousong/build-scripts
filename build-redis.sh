#!/bin/bash -e
#
# Copyright 2015-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Test
#
#	./runtest --help
#	./runtest --list-tests
#	./runtest --single unit/printver
#
# Speed regression when within code repo (patch needed)
#
#	( cd utils; ./speed-regression.tcl --help )
#	( cd utils; ./speed-regression.tcl )
#
# Cluster
#
#	( cd ./utils/create-cluster; ./create-cluster help )
#	( cd ./utils/create-cluster; ./create-cluster start )
#	( cd ./utils/create-cluster; ./create-cluster create )
#	( cd ./utils/create-cluster; ./create-cluster stop )
#	( cd ./utils/create-cluster; ./create-cluster clean )
#
# Test requires tclsh version of at least 8.5.
#
# Tests are run by firstly starting a single test server which in turn will
# spawn (--clients) <num> test clients.  Test server waits for connections from
# test clients, then distribute tests to clients and collect test results.
# Test clients may start redis servers with ports selected from a range
# prepared by test server before spawning test client.
#
# There is a Tcl implementation of redis client at tests/support/redis.tcl
#
# Speed regression evaluation is performed by
#
# 0. git checkout branch and build src/redis-benchmark
# 1. git checkout branch
# 2. build src/redis-server
# 3. redis-benchmark against it
# 4. combine benchmark result and present it in units of request per second
#
# The shell script create-cluster depends on src/redis-trib.rb which requires
# Ruby implementation of redis client
#
PKG_NAME=redis
PKG_VERSION=5.0.14
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://download.redis.io/releases/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=406a4ddbdf0b60b4f288bf0c3cb06933

. "$PWD/env.sh"

# verbose output instead of colorful output for better logging
MAKE_VARS+=(
	V=1
)
# redis has its own Lua source packaged and is almost self-contained
if os_is_darwin; then
	EXTRA_CPPFLAGS=()
	EXTRA_CFLAGS=()
	EXTRA_LDFLAGS=()
fi

configure() {
	true
}

staging() {
	cd "$PKG_BUILD_DIR"
	# build system of redis just install all its binaries in bin/ directory
	"${MAKEJ[@]}" PREFIX="$PKG_STAGING_DIR/$INSTALL_PREFIX" install
}
