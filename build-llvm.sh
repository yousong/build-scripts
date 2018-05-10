#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# LLVM as of 3.9.1 requires at least
#
#  - cmake version 3.4.3
#  - GCC 4.8
#
# Links
#
#  - http://releases.llvm.org/download.html
#  - http://www.llvm.org/docs/GettingStarted.html
#
#    - Hardware/software requirements
#    - Installation howto

LLVM_VERSION=6.0.0

PKG_NAME=llvm
PKG_VERSION=$LLVM_VERSION
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.src.tar.xz"
PKG_SOURCE_URL="http://llvm.org/releases/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=788a11a35fa62eb008019b37187d09d2
PKG_DEPENDS='cmake zlib gcc-cross-pass2'
PKG_CMAKE=1

PKG_clang_NAME=clang
PKG_clang_VERSION=$LLVM_VERSION
PKG_clang_SOURCE="cfe-$PKG_clang_VERSION.src.tar.xz"
PKG_clang_SOURCE_URL="http://llvm.org/releases/$PKG_clang_VERSION/$PKG_clang_SOURCE"
PKG_clang_SOURCE_MD5SUM=121b3896cb0c7765d690acc5d9495d24

# "compiler-rt" runtime libraries, http://compiler-rt.llvm.org/index.html
#
# - builtins
# - sanitizer runtimes
# - profile
# - BlocksRuntime
PKG_compiler_rt_NAME=compiler-rt
PKG_compiler_rt_VERSION=$LLVM_VERSION
PKG_compiler_rt_SOURCE="compiler-rt-$PKG_compiler_rt_VERSION.src.tar.xz"
PKG_compiler_rt_SOURCE_URL="http://llvm.org/releases/$PKG_compiler_rt_VERSION/$PKG_compiler_rt_SOURCE"
PKG_compiler_rt_SOURCE_MD5SUM=ba6368e894b5528e527d86a69d8533c6

PKG_libcxx_NAME=libcxx
PKG_libcxx_VERSION=$LLVM_VERSION
PKG_libcxx_SOURCE="libcxx-$PKG_libcxx_VERSION.src.tar.xz"
PKG_libcxx_SOURCE_URL="http://llvm.org/releases/$PKG_libcxx_VERSION/$PKG_libcxx_SOURCE"
PKG_libcxx_SOURCE_MD5SUM=4ecad7dfd8ea636205d3ffef028df73a

PKG_libcxxabi_NAME=libcxxabi
PKG_libcxxabi_VERSION=$LLVM_VERSION
PKG_libcxxabi_SOURCE="libcxxabi-$PKG_libcxxabi_VERSION.src.tar.xz"
PKG_libcxxabi_SOURCE_URL="http://llvm.org/releases/$PKG_libcxxabi_VERSION/$PKG_libcxxabi_SOURCE"
PKG_libcxxabi_SOURCE_MD5SUM=9d06327892fc5d8acec4ef2e2821ab3d

# test-suite too big: about 113MB as of version 3.9.1
PKG_test_suite_NAME=test-suite
PKG_test_suite_VERSION=$LLVM_VERSION
PKG_test_suite_SOURCE="test-suite-$PKG_test_suite_VERSION.src.tar.xz"
PKG_test_suite_SOURCE_URL="http://llvm.org/releases/$PKG_test_suite_VERSION/$PKG_test_suite_SOURCE"
PKG_test_suite_SOURCE_MD5SUM=x

. "$PWD/env.sh"

download_extra() {
	download_http "$PKG_clang_SOURCE"		"$PKG_clang_SOURCE_URL"			"$PKG_clang_SOURCE_MD5SUM"
	download_http "$PKG_compiler_rt_SOURCE"	"$PKG_compiler_rt_SOURCE_URL"	"$PKG_compiler_rt_SOURCE_MD5SUM"
	download_http "$PKG_libcxx_SOURCE"		"$PKG_libcxx_SOURCE_URL"		"$PKG_libcxx_SOURCE_MD5SUM"
	download_http "$PKG_libcxxabi_SOURCE"	"$PKG_libcxxabi_SOURCE_URL"		"$PKG_libcxxabi_SOURCE_MD5SUM"
}

prepare_extra() {
	unpack "$BASE_DL_DIR/$PKG_clang_SOURCE"			"$PKG_SOURCE_DIR/tools/"	"s:^[^/]\\+:clang:"
	unpack "$BASE_DL_DIR/$PKG_compiler_rt_SOURCE"	"$PKG_SOURCE_DIR/projects/"	"s:^[^/]\\+:compiler-rt:"
	unpack "$BASE_DL_DIR/$PKG_libcxx_SOURCE"		"$PKG_SOURCE_DIR/projects/"	"s:^[^/]\\+:libcxx:"
	unpack "$BASE_DL_DIR/$PKG_libcxxabi_SOURCE"		"$PKG_SOURCE_DIR/projects/"	"s:^[^/]\\+:libcxxabi:"
}

. $PWD/utils-toolchain.sh

ORIG_INSTALL_PREFIX="$INSTALL_PREFIX"
TOOLCHAIN_DIR_BASE="$ORIG_INSTALL_PREFIX/toolchain"
INSTALL_PREFIX="$TOOLCHAIN_DIR_BASE/llvm-$LLVM_VERSION"

GNU_TOOLCHAIN_DIR="$TOOLCHAIN_DIR_BASE/$GNU_TOOLCHAIN_NAME"
GNU_TOOLCHAIN_DIR_BIN="$GNU_TOOLCHAIN_DIR/bin"
GNU_TOOLCHAIN_DIR_LIB="$GNU_TOOLCHAIN_DIR/lib"

EXTRA_LDFLAGS+=( -Wl,--dynamic-linker="$GNU_TOOLCHAIN_DIR_LIB/ld-linux-x86-64.so.2" )
EXTRA_LDFLAGS+=( -Wl,-rpath "$GNU_TOOLCHAIN_DIR_LIB" )
EXTRA_LDFLAGS+=( -L"$GNU_TOOLCHAIN_DIR_LIB" )

# Requires at least GCC 4.8
CMAKE_ENVS+=(
	CC="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-gcc"
	CXX="$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-g++"
)
CMAKE_ARGS+=(
	-G 'Unix Makefiles'
)
