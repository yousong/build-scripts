#!/bin/bash -e
#
# Copyright 2015-2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# To use go plugin
#
#	go get -u github.com/golang/protobuf/protoc-gen-go
#	protoc --go_out=. *.proto
#
# - Language Guide (proto2), https://developers.google.com/protocol-buffers/docs/proto
# - Language Guide (proto3), https://developers.google.com/protocol-buffers/docs/proto3
# - Techniques, https://developers.google.com/protocol-buffers/docs/techniques
#
#	- protobuf messages are not self-delimiting
#	- not for bulk data transfer
#
# - Protocol Buffer Basics: Go, https://developers.google.com/protocol-buffers/docs/gotutorial
#
PKG_NAME=protobuf
PKG_VERSION="3.14.0"
PKG_SOURCE="protobuf-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/google/protobuf/archive/v$PKG_VERSION.tar.gz"

# versions of googlemock and googletest are required as specified in the autogen.sh
PKG_googlemock_VERSION=1.7.0
PKG_googlemock_SOURCE="googlemock-$PKG_googlemock_VERSION.tar.gz"
PKG_googlemock_SOURCE_URL="https://github.com/google/googlemock/archive/release-$PKG_googlemock_VERSION.tar.gz"
PKG_googlemock_SOURCE_MD5SUM=

PKG_googletest_VERSION=1.7.0
PKG_googletest_SOURCE="googletest-$PKG_googletest_VERSION.tar.gz"
PKG_googletest_SOURCE_URL="https://github.com/google/googletest/archive/release-$PKG_googletest_VERSION.tar.gz"
PKG_googletest_SOURCE_MD5SUM=

. "$PWD/env.sh"

# If you get linker errors about undefined references to symbols that involve
# types in the std::__cxx11 namespace or the tag [abi:cxx11] then it probably
# indicates that you are trying to link together object files that were compiled
# with different values for the _GLIBCXX_USE_CXX11_ABI macro. This commonly
# happens when linking to a third-party library that was compiled with an older
# version of GCC. If the third-party library cannot be rebuilt with the new ABI
# then you will need to recompile your code with the old ABI.
#
# https://gcc.gnu.org/onlinedocs/gcc-5.2.0/libstdc++/manual/manual/using_dual_abi.html
#
#env_init_gnu_toolchain

download_extra() {
	download_http "$PKG_googlemock_SOURCE"		"$PKG_googlemock_SOURCE_URL"			"$PKG_googlemock_SOURCE_MD5SUM"
	download_http "$PKG_googletest_SOURCE"		"$PKG_googletest_SOURCE_URL"			"$PKG_googletest_SOURCE_MD5SUM"
}

prepare_extra() {
	unpack "$BASE_DL_DIR/$PKG_googlemock_SOURCE"	"$PKG_SOURCE_DIR"		"s:^[^/]\\+:gmock:"
	unpack "$BASE_DL_DIR/$PKG_googletest_SOURCE"	"$PKG_SOURCE_DIR/gmock"	"s:^[^/]\\+:gtest:"
}

configure_pre() {
	cd "$PKG_SOURCE_DIR"
	./autogen.sh
}

protobuf_use_prebuilt() {
	local ver="$PKG_VERSION"
	local comp_src="protoc-$ver-linux-x86_64.zip"
	local comp_url="https://github.com/protocolbuffers/protobuf/releases/download/v$ver/$comp_src"
	local comp_src_csum='cef4dc2f438e44e5d1af64ba4f9dbaa6'
	local lang_src="protobuf-all-$ver.tar.gz"
	local lang_url="https://github.com/protocolbuffers/protobuf/releases/download/v$ver/$lang_src"
	local lang_src_csum='d0a7dd930210af5285c08c8a2c2304ab'

	download_http "$comp_src" "$comp_url" "$comp_src_csum"
	unpack "$BASE_DL_DIR/$comp_src"	"$INSTALL_PREFIX"

	download_http "$lang_src" "$lang_url" "$lang_src_csum"
	mkdir -p "$INSTALL_PREFIX/protobuf"
	unpack "$BASE_DL_DIR/$lang_src"	"$INSTALL_PREFIX/protobuf"
}
