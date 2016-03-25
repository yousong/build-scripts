#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# glibc requires out of tree build, i.e. it will fail explicitly if configure
# was run in source tree
#
# - Compiling glibc, Frequently Asked Questions about the GNU C Library, https://sourceware.org/glibc/wiki/FAQ
#
PKG_NAME=glibc-final
PKG_VERSION=2.23
PKG_SOURCE="glibc-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://ftpmirror.gnu.org/glibc/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=456995968f3acadbed39f5eba31678df
PKG_DEPENDS="gcc-pass1 kernel-headers"

. "$PWD/env.sh"
. "$PWD/utils-toolchain.sh"
toolchain_init

prepare_extra() {
	toolchain_prepare_extra
}

configure_pre() {
	toolchain_configure_pre
}

# XXX: gcc-pass1 is built with --disable-libssp so it does not provide
# stack_chk_guard at the moment, yet the compiler does not fail when supplied
# with -fstack-protector flag, so we need to force disabling the use of ssp at
# the moment
CONFIGURE_VARS="$CONFIGURE_VARS					\\
	libc_cv_forced_unwind=yes					\\
	libc_cv_ctors_header=yes					\\
	libc_cv_c_cleanup=yes						\\
	libc_cv_ssp=no								\\
	libc_cv_ssp_strong=no						\\
"

CONFIGURE_ARGS="$CONFIGURE_ARGS					\\
	--build='$TRI_BUILD'						\\
	--host='$TRI_TARGET'						\\
	--with-headers='$TOOLCHAIN_DIR/include'		\\
	--enable-kernel=2.6.32						\\
	--disable-werror							\\
"

EXTRA_CFLAGS="$EXTRA_CFLAGS -O"

staging() {
	local libdir="$PKG_STAGING_DIR$TOOLCHAINDIR"

	build_staging 'install'
}
