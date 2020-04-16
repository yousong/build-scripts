#!/bin/bash -e
#
# Copyright 2017-2020 (c) Yousong Zhou
#
# LLVM as of 3.9.1 requires at least
#
#  - cmake version 3.4.3
#  - GCC 4.8
#
# LLVM as of 8.0.1
#
#  - Recommends GCC of version at least 5.1
#
# Links
#
#  - http://releases.llvm.org/download.html
#  - http://www.llvm.org/docs/GettingStarted.html
#
#    - Hardware/software requirements
#    - Installation howto
#
#  - RFC: Default path for cross-compiled runtimes,
#    http://lists.llvm.org/pipermail/llvm-dev/2017-December/119864.html
#
#	 As of 2017-12-19, libcxx and libcxxabi does not have proper directory
#	 layout for multilib support
#
# Dependencies
#
#  - z3, a constraint solver library, mainly for clang static analyzer

. "$PWD/utils-llvm.sh"

PKG_NAME=llvm
PKG_VERSION=$LLVM_VERSION
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.src.tar.xz"
PKG_SOURCE_URL="$LLVM_SOURCE_URL_BASE/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=693cefdc49d618f828144486a18b473f
PKG_DEPENDS='cmake lxml2 z3 zlib gcc-cross-pass2'
PKG_CMAKE=1

# - Assembling a complete toolchain, https://clang.llvm.org/docs/Toolchain.html
#
#	It covers topics like language frontend, assembler, linker, and runtime
#	libraries like compiler-rt, libgcc, libatmoic, libunwind etc.
#
PKG_clang_NAME=clang
PKG_clang_VERSION=$LLVM_VERSION
PKG_clang_SOURCE="clang-$PKG_clang_VERSION.src.tar.xz"
PKG_clang_SOURCE_URL="$LLVM_SOURCE_URL_BASE/$PKG_clang_SOURCE"
PKG_clang_SOURCE_MD5SUM=717ef92318fed4dbe1ee058368cfb552

PKG_clang_tools_extra_NAME=clang-tools-extra
PKG_clang_tools_extra_VERSION=$LLVM_VERSION
PKG_clang_tools_extra_SOURCE="clang-tools-extra-$PKG_clang_tools_extra_VERSION.src.tar.xz"
PKG_clang_tools_extra_SOURCE_URL="$LLVM_SOURCE_URL_BASE/$PKG_clang_tools_extra_SOURCE"
PKG_clang_tools_extra_SOURCE_MD5SUM=19adb2918e88d682ba2f97ac7280a25d

# "compiler-rt" runtime libraries, http://compiler-rt.llvm.org/index.html
#
#  - builtins
#  - sanitizer runtimes
#  - profile
#  - BlocksRuntime
#
# By default only arch x86_64 will be compiled.  It will be installed under
# $INSTALL_PREFIX/lib/clang/$LLVM_VERSION/lib/<OS>/libclang_rt.*
#
# Clang will default to use compiler-rt when possible.  Use -rtlib=compiler-rt,
# -rtlib=libgcc to change the default
PKG_compiler_rt_NAME=compiler-rt
PKG_compiler_rt_VERSION=$LLVM_VERSION
PKG_compiler_rt_SOURCE="compiler-rt-$PKG_compiler_rt_VERSION.src.tar.xz"
PKG_compiler_rt_SOURCE_URL="$LLVM_SOURCE_URL_BASE/$PKG_compiler_rt_SOURCE"
PKG_compiler_rt_SOURCE_MD5SUM=3a8477233f69600f3e2ca997405c29db

PKG_libcxx_NAME=libcxx
PKG_libcxx_VERSION=$LLVM_VERSION
PKG_libcxx_SOURCE="libcxx-$PKG_libcxx_VERSION.src.tar.xz"
PKG_libcxx_SOURCE_URL="$LLVM_SOURCE_URL_BASE/$PKG_libcxx_SOURCE"
PKG_libcxx_SOURCE_MD5SUM=24162978c9373ac2a9bab96bb7d58fe9

PKG_libcxxabi_NAME=libcxxabi
PKG_libcxxabi_VERSION=$LLVM_VERSION
PKG_libcxxabi_SOURCE="libcxxabi-$PKG_libcxxabi_VERSION.src.tar.xz"
PKG_libcxxabi_SOURCE_URL="$LLVM_SOURCE_URL_BASE/$PKG_libcxxabi_SOURCE"
PKG_libcxxabi_SOURCE_MD5SUM=3d62a97e98ff57d6b46881d0b014a589

# A linker, https://lld.llvm.org/
#
# To use it
#
#	./clang \
#		--sysroot=$HOME/git-repo/lede-project/lede/staging_dir/toolchain-mips_24kc_gcc-7.3.0_glibc \
#		-target mips-openwrt-linux-gnu \
#		-mfloat-abi=soft \
#		-fuse-ld=lld \
#		-Wl,-dynamic-linker -Wl,/lib/ld-musl-mips-sf.so.1 \
#		-v \
#		-o a a.c
#
#	./clang \
#		--sysroot=$HOME/git-repo/lede-project/lede/staging_dir/toolchain-mips_24kc_gcc-7.3.0_musl \
#		-target mips-openwrt-linux-musl \
#		-mfloat-abi=soft \
#		-fuse-ld=lld \
#		-Wl,-dynamic-linker -Wl,/lib/ld-musl-mips-sf.so.1 \
#		-v \
#		-o a a.c
#
# LLVM is born cross-capable ;) Linker will need -sysroot to find "crt*.o" and
# "libgcc*" under "$sysroot/lib/gcc/$target".  The simple test above have the
# following result
#
#  - glibc: compiles and run with OpenWrt malta musl machine
#  - musl: compiles but segfault when running in OpenWrt malta musl machine
#
#		root@OpenWrt:/tmp# /tmp/a
#		[  677.202865] do_page_fault(): sending SIGSEGV to a for invalid write access to 00020000
#		[  677.207014] epc = 77f6e8f0 in libc.so[77eeb000+92000]
#		[  677.210336] ra  = 77f6e3b8 in libc.so[77eeb000+92000]
#
PKG_lld_NAME=lld
PKG_lld_VERSION=$LLVM_VERSION
PKG_lld_SOURCE="lld-$PKG_lld_VERSION.src.tar.xz"
PKG_lld_SOURCE_URL="$LLVM_SOURCE_URL_BASE/$PKG_lld_SOURCE"
PKG_lld_SOURCE_MD5SUM=481ab4e01c8c5549c8aff5ef1bd25425

# Golang frontend: there are actually two.  One already in llvm upstream,
# another accepted by the Google Golang team.
#
# - http://llvm.org/svn/llvm-project/llgo/trunk/README.TXT
#
#   > llgo is a Go (http://golang.org) frontend for LLVM, written in Go.
#   >
#   > llgo is under active development. It compiles and passes most of the standard
#   > library test suite and a substantial portion of the gc test suite, but there
#   > are some corner cases that are known not to be handled correctly yet.
#   > Nevertheless it can compile modestly substantial programs (including itself;
#   > it is self hosting on x86-64 Linux).
#
#
# - https://go.googlesource.com/gollvm/
#
#   > Gollvm is an LLVM-based Go compiler. It incorporates “gofrontend” (a Go
#   > language front end written in C++ and shared with GCCGO), a bridge component
#   > (which translates from gofrontend IR to LLVM IR), and a driver that sends the
#   > resulting IR through the LLVM back end.
#
# There is also tools/llvm-go.  Looks like it's for working with $GOPATH.  How
# and where it was used is unclear

# test-suite too big: about 113MB as of version 3.9.1
PKG_test_suite_NAME=test-suite
PKG_test_suite_VERSION=$LLVM_VERSION
PKG_test_suite_SOURCE="test-suite-$PKG_test_suite_VERSION.src.tar.xz"
PKG_test_suite_SOURCE_URL="$LLVM_SOURCE_URL_BASE/$PKG_test_suite_SOURCE"
PKG_test_suite_SOURCE_MD5SUM=x

. "$PWD/env.sh"

download_extra() {
	download_http "$PKG_clang_SOURCE"	"$PKG_clang_SOURCE_URL"		"$PKG_clang_SOURCE_MD5SUM"
	download_http "$PKG_clang_tools_extra_SOURCE"	"$PKG_clang_tools_extra_SOURCE_URL"		"$PKG_clang_tools_extra_SOURCE_MD5SUM"
	download_http "$PKG_lld_SOURCE"		"$PKG_lld_SOURCE_URL"		"$PKG_lld_SOURCE_MD5SUM"
	download_http "$PKG_compiler_rt_SOURCE"	"$PKG_compiler_rt_SOURCE_URL"	"$PKG_compiler_rt_SOURCE_MD5SUM"
	download_http "$PKG_libcxx_SOURCE"	"$PKG_libcxx_SOURCE_URL"	"$PKG_libcxx_SOURCE_MD5SUM"
	download_http "$PKG_libcxxabi_SOURCE"	"$PKG_libcxxabi_SOURCE_URL"	"$PKG_libcxxabi_SOURCE_MD5SUM"
}

prepare_extra() {
	unpack "$BASE_DL_DIR/$PKG_clang_SOURCE"		"$PKG_SOURCE_DIR/tools/"	"s:^[^/]\\+:clang:"
	unpack "$BASE_DL_DIR/$PKG_clang_tools_extra_SOURCE"		"$PKG_SOURCE_DIR/tools/clang/tools"	"s:^[^/]\\+:extra:"
	unpack "$BASE_DL_DIR/$PKG_lld_SOURCE"		"$PKG_SOURCE_DIR/tools/"	"s:^[^/]\\+:lld:"
	unpack "$BASE_DL_DIR/$PKG_compiler_rt_SOURCE"	"$PKG_SOURCE_DIR/runtimes/"	"s:^[^/]\\+:compiler-rt:"
	unpack "$BASE_DL_DIR/$PKG_libcxx_SOURCE"	"$PKG_SOURCE_DIR/projects/"	"s:^[^/]\\+:libcxx:"
	unpack "$BASE_DL_DIR/$PKG_libcxxabi_SOURCE"	"$PKG_SOURCE_DIR/projects/"	"s:^[^/]\\+:libcxxabi:"
}

. $PWD/utils-toolchain.sh

ORIG_INSTALL_PREFIX="$INSTALL_PREFIX"
TOOLCHAIN_DIR_BASE="$ORIG_INSTALL_PREFIX/toolchain"
INSTALL_PREFIX="$TOOLCHAIN_DIR_BASE/llvm-$LLVM_VERSION"

LLVM_USE_BUILT_TOOLCHAIN=0
if [ "$LLVM_USE_BUILT_TOOLCHAIN" -gt 0 ];  then
	GNU_TOOLCHAIN_DIR="$TOOLCHAIN_DIR_BASE/$GNU_TOOLCHAIN_NAME"
	if [ ! -d "$GNU_TOOLCHAIN_DIR" ]; then
		__errmsg "GNU toolchain is not built yet: $GNU_TOOLCHAIN_DIR"
		false
	fi

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
fi

# To avoid link failure caused by "-lz -lcurses".  See cmake/config-ix.cmake.
#
# For some reason, the linker -L option is present when configuring, yet absent
# at the compiling stage
CMAKE_ARGS+=(
	-DLLVM_ENABLE_ZLIB=off
	-DLLVM_ENABLE_LIBEDIT=off
	-DLLVM_ENABLE_TERMINFO=off
	-DLLVM_ENABLE_LIBXML2=off
)

CMAKE_ARGS+=(
	-G 'Unix Makefiles'
)
