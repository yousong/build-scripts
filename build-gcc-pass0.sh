#!/bin/sh -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# gcc-pass0 is for preparing GCC source code for later passes
#
. "$PWD/utils-toolchain.sh"
toolchain_init_pkg gcc
PKG_NAME=gcc-pass0

. "$PWD/env.sh"

TOOLCHAIN_GCC_SUPPORT_LIBS='mpfr gmp mpc'

PKG_gmp_VERSION=6.1.0
PKG_gmp_SOURCE="gmp-$PKG_gmp_VERSION.tar.xz"
PKG_gmp_SOURCE_URL="https://gmplib.org/download/gmp/$PKG_gmp_SOURCE"
PKG_gmp_SOURCE_MD5SUM=a9868ef2556ad6a2909babcd1428f3c7

PKG_mpfr_VERSION=3.1.4
PKG_mpfr_SOURCE="mpfr-$PKG_mpfr_VERSION.tar.xz"
PKG_mpfr_SOURCE_URL="http://www.mpfr.org/mpfr-current/$PKG_mpfr_SOURCE"
PKG_mpfr_SOURCE_MD5SUM=064b2c18185038e404a401b830d59be8

PKG_mpc_VERSION=1.0.3
PKG_mpc_SOURCE="mpc-$PKG_mpc_VERSION.tar.gz"
PKG_mpc_SOURCE_URL="ftp://ftp.gnu.org/gnu/mpc/$PKG_mpc_SOURCE"
PKG_mpc_SOURCE_MD5SUM=d6a1d5f8ddea3abd2cc3e98f58352d26

download_extra() {
	local lib
	local file url csum

	for lib in $TOOLCHAIN_GCC_SUPPORT_LIBS; do
		file="$(eval "echo \$PKG_${lib}_SOURCE")"
		url="$(eval "echo \$PKG_${lib}_SOURCE_URL")"
		csum="$(eval "echo \$PKG_${lib}_SOURCE_MD5SUM")"
		download_http "$file" "$url" "$csum"
	done
}

prepare_extra() {
	local lib
	local file

	for lib in $TOOLCHAIN_GCC_SUPPORT_LIBS; do
		file="$(eval "echo \$PKG_${lib}_SOURCE")"
		untar "$BASE_DL_DIR/$file" "$PKG_SOURCE_DIR" "s,^$lib[^/]*,$lib,"
	done

	sed -i'' -e 's,gcc_no_link=yes,gcc_no_link=no,' "$PKG_SOURCE_DIR/libstdc++-v3/configure"
}

configure() {
	true
}

compile() {
	true
}

staging() {
	true
}

install() {
	true
}
