#!/bin/bash -e
#
# Copyright 2017-2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=bcc
PKG_VERSION=0.10.0
PKG_SOURCE_VERSION="$PKG_VERSION"
PKG_SOURCE="$PKG_NAME-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/iovisor/bcc/archive/v$PKG_SOURCE_VERSION.tar.gz"
PKG_DEPENDS='luajit libelf'
PKG_SOURCE_UNTAR_FIXUP=1
PKG_CMAKE=1

. "$PWD/env.sh"
env_init_llvm_toolchain

libbpf_SOURCE_URL="https://github.com/libbpf/libbpf.git"
libbpf_VERSION=59a6415
libbpf_SOURCE=libbpf-2019-05-24.tar.gz

download_extra() {
	download_git libbpf "$libbpf_SOURCE_URL" "$libbpf_VERSION" "$libbpf_SOURCE"
}

prepare_extra() {
	unpack "$BASE_DL_DIR/$libbpf_SOURCE" "$PKG_SOURCE_DIR/src/cc" "s:^[^/]\\+:libbpf:"
}

EXTRA_CXXFLAGS+=(
	-D_GLIBCXX_USE_CXX11_ABI=1
)
CMAKE_ARGS+=(
	-DLLVM_DIR="$LLVM_DIR/lib/cmake/llvm"
)
