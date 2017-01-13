#!/bin/sh -e
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

LLVM_VERSION=3.9.1

PKG_NAME=llvm
PKG_VERSION=$LLVM_VERSION
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.src.tar.xz"
PKG_SOURCE_URL="http://llvm.org/releases/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=3259018a7437e157f3642df80f1983ea
PKG_DEPENDS='cmake zlib'
PKG_CMAKE=1

PKG_clang_NAME=clang
PKG_clang_VERSION=$LLVM_VERSION
PKG_clang_SOURCE="cfe-$PKG_clang_VERSION.src.tar.xz"
PKG_clang_SOURCE_URL="http://llvm.org/releases/$PKG_clang_VERSION/$PKG_clang_SOURCE"
PKG_clang_SOURCE_MD5SUM=45713ec5c417ed9cad614cd283d786a1

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
PKG_compiler_rt_SOURCE_MD5SUM=aadc76e7e180fafb10fb729444e287a3

PKG_libcxx_NAME=libcxx
PKG_libcxx_VERSION=$LLVM_VERSION
PKG_libcxx_SOURCE="libcxx-$PKG_libcxx_VERSION.src.tar.xz"
PKG_libcxx_SOURCE_URL="http://llvm.org/releases/$PKG_libcxx_VERSION/$PKG_libcxx_SOURCE"
PKG_libcxx_SOURCE_MD5SUM=75a3214224301fc543fa6a38bdf7efe0

PKG_libcxxabi_NAME=libcxxabi
PKG_libcxxabi_VERSION=$LLVM_VERSION
PKG_libcxxabi_SOURCE="libcxxabi-$PKG_libcxxabi_VERSION.src.tar.xz"
PKG_libcxxabi_SOURCE_URL="http://llvm.org/releases/$PKG_libcxxabi_VERSION/$PKG_libcxxabi_SOURCE"
PKG_libcxxabi_SOURCE_MD5SUM=62fd584b38cc502172c2ffab041b5fcc

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
	untar "$BASE_DL_DIR/$PKG_clang_SOURCE"			"$PKG_SOURCE_DIR/tools/"	"s:^[^/]\\+:clang:"
	untar "$BASE_DL_DIR/$PKG_compiler_rt_SOURCE"	"$PKG_SOURCE_DIR/projects/"	"s:^[^/]\\+:compiler-rt:"
	untar "$BASE_DL_DIR/$PKG_libcxx_SOURCE"			"$PKG_SOURCE_DIR/projects/"	"s:^[^/]\\+:libcxx:"
	untar "$BASE_DL_DIR/$PKG_libcxxabi_SOURCE"		"$PKG_SOURCE_DIR/projects/"	"s:^[^/]\\+:libcxxabi:"
}

. $PWD/utils-toolchain.sh

ORIG_INSTALL_PREFIX="$INSTALL_PREFIX"
TOOLCHAIN_DIR_BASE="$ORIG_INSTALL_PREFIX/toolchain"
INSTALL_PREFIX="$TOOLCHAIN_DIR_BASE/llvm-$LLVM_VERSION"

GNU_TOOLCHAIN_DIR="$TOOLCHAIN_DIR_BASE/$GNU_TOOLCHAIN_NAME"
GNU_TOOLCHAIN_DIR_BIN="$GNU_TOOLCHAIN_DIR/bin"
GNU_TOOLCHAIN_DIR_LIB="$GNU_TOOLCHAIN_DIR/lib"

EXTRA_LDFLAGS="$EXTRA_LDFLAGS -Wl,--dynamic-linker=$GNU_TOOLCHAIN_DIR_LIB/ld-linux-x86-64.so.2"
EXTRA_LDFLAGS="$EXTRA_LDFLAGS -Wl,-rpath $GNU_TOOLCHAIN_DIR_LIB"
EXTRA_LDFLAGS="$EXTRA_LDFLAGS -L $GNU_TOOLCHAIN_DIR_LIB"

# Requires at least GCC 4.8
CMAKE_ENVS="$CMAKE_ENVS							\\
	CC=$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-gcc	\\
	CXX=$GNU_TOOLCHAIN_DIR_BIN/$TRI_TARGET-g++	\\
"
CMAKE_ARGS="$CMAKE_ARGS	\\
	-G 'Unix Makefiles'	\\
"
