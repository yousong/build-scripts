#!/bin/bash -e
#
# Copyright 2021 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=capnproto
PKG_VERSION=0.9.1
PKG_SOURCE="$PKG_NAME-c++-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://capnproto.org/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=4e86cda4bd894c94b1ac96bf3c447b8e

. "$PWD/env.sh"

check() {
	# Issue: https://github.com/capnproto/capnproto/issues/1398
	#
	# Run tests
	#
	#	./capnp-test --list | grep  AncillaryMessageHandler
	#	./capnp-test --verbose --filter=kj/async-io-test.c++:307
	#
	cd "$PKG_BUILD_DIR"
	"${MAKEJ[@]}" check
}
