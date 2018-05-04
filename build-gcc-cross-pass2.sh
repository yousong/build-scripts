#!/bin/bash -e
#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
. "$PWD/utils-toolchain.sh"
toolchain_init_pkg gcc
PKG_NAME=gcc-cross-pass2
PKG_DEPENDS="glibc-cross"

. "$PWD/env.sh"
toolchain_init_vars_build_cross "$PKG_NAME"

# libssp can be disabled here because we expect it to be provided by libc which
# is true with musl, bionic and glibc since 2.4.  See LIBC_PROVIDES_SSP in
# gcc/configure.ac and gcc/gcc.c for details.
#
# When ssp is not provided by libc, the link step will link against libssp.a
# and libssp_nonshared.a which can be provided by libssp/ provided by GCC.
# However libssp is a target library depending on presence of libc and as such
# cannot be enabled on gcc pass1
#
# libssp_nonshared.a is expected to contain visibility("hidden") function
# __stack_chk_fail_local().  This function is used so that the generated code
# does not need to setup GP register (PIC/PIE).  At the moment this
# optimization is only applied to x86_32 and powerpc 32 target.  Details can be
# found by searching for caller of default_hidden_stack_protect_fail in
# gcc/targhooks.c.
#
# LTO is not a language but will be enabled by default because
# --enabled-default is the default.  We enable it explicitly just in case
CONFIGURE_ARGS+=(
	--build="$TRI_BUILD"
	--host="$TRI_HOST"
	--target="$TRI_TARGET"
	--with-headers="$TOOLCHAIN_DIR/include"
	--disable-multilib
	--disable-nls
	--enable-shared
	--enable-threads
	--enable-lto
	--disable-libgomp
	--disable-libmudflap
)

# GCC 8.1.0 does not yet support golang for RISC-V.  libffi is too old
# (requires v3.3, see configure.host)
#
# Also useful info on issues of GCC riscv support as of 2018-04-09 by Jim
# Wilson of sifive.com, https://gcc.gnu.org/ml/gcc/2018-04/msg00052.html
#
# For gccgo MIPS support, it all did not compile when gcc was configured with
# --with-float=soft.  See https://github.com/libffi/libffi/pull/272
case "$TRI_ARCH" in
	riscv*) CONFIGURE_ARGS+=( --enable-languages=c,c++ ) ;;
	*) CONFIGURE_ARGS+=( --enable-languages=c,c++,go ) ;;
esac

compile() {
	build_compile_make 'all'
}

staging() {
	local base="$PKG_STAGING_DIR$TOOLCHAIN_DIR"

	# GCC will install directory lib/ and lib64/ there which is at the moement
	# symbolic links created at the installation of binutils
	mkdir -p "$base/$TRI_TARGET"
	ln -s lib "$base/lib64"
	ln -s ../lib "$base/$TRI_TARGET/lib"
	ln -s ../lib "$base/$TRI_TARGET/lib64"

	build_staging 'install'
}
