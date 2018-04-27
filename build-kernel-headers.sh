#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
. "$PWD/utils-toolchain.sh"
toolchain_init_pkg linux
PKG_NAME=kernel-headers
PKG_PLATFORM=linux

. "$PWD/env.sh"
toolchain_init_vars_build_cross "$PKG_NAME"

RISCV_KERNEL_VERSION="9079be6167aec516a4625b7dcf20efbf384277b4"
RISCV_KERNEL_URL="https://github.com/riscv/riscv-linux/archive/$RISCV_KERNEL_VERSION.tar.gz"
RISCV_KERNEL_SOURCE="riscv-linux-$RISCV_KERNEL_VERSION.tar.gz"

download_extra() {
	local csum

	download_http "$RISCV_KERNEL_SOURCE" "$RISCV_KERNEL_URL" "$csum"
}

prepare_extra() {
	unpack "$BASE_DL_DIR/$RISCV_KERNEL_SOURCE" "$PKG_SOURCE_DIR" "s:^[^/]\\+::"
}

configure() {
	true
}

compile() {
	true
}

staging() {
	local arch

	case "$TRI_ARCH" in
		arm|armeb)
			arch=arm
			;;
		aarch64|aarch64_be)
			arch=arm64
			;;
		mips|mipsel|mips64|mips64el)
			arch=mips
			;;
		i686|x86_64)
			arch=x86
			;;
		riscv32|riscv64)
			arch=riscv
			;;
		*)
			__errmsg "unknown TRI_ARCH: $TRI_ARCH"
			return 1
	esac

	# it is said that INSTALL_HDR_PATH will be cleaned up when making
	# headers_install, so the staging step here is actually required
	cd "$PKG_SOURCE_DIR"
	"${MAKEJ[@]}" \
		ARCH="$arch" \
		INSTALL_HDR_PATH="$PKG_STAGING_DIR$INSTALL_PREFIX" \
			headers_install
}

install() {
	mkdir -p "$TOOLCHAIN_DIR"
	cpdir "$PKG_STAGING_DIR$INSTALL_PREFIX" "$TOOLCHAIN_DIR"
}
