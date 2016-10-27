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
# To debug dynamic linker, try LD_DEBUG.  It's far better a facility than
# strace on this job
#
#	LD_DEBUG=all cat
#	LD_TRACE_LOADED_OBJECTS=1 cat
#	LD_TRACE_LOADED_OBJECTS=1 LD_VERBOSE=1 cat
#
# - Compiling glibc, Frequently Asked Questions about the GNU C Library, https://sourceware.org/glibc/wiki/FAQ
# - ld.so, ld-linux.so* - dynamic linker/loader, http://man7.org/linux/man-pages/man8/ld.so.8.html
# - Mini FAQ about the misc libc/gcc crt files. https://dev.gentoo.org/~vapier/crt.txt
#
#	A table
#
#		crt0.o, crt1.o			start.S				_start
#		crti.o, crtn.o			crti.S, crtn.S		prolog, epilog for code inside .init, .fini sections
#		crtbegin.o, crtend.o	libgcc/crtstuff.c	find the start of constructors/destructors
#		crtbeginS.o, crtendS.o						for shared objects/PIEs
#		crtbeginT.o				                 	for static executables
#
#	General linking order:
#
#		crt1.o crti.o crtbegin.o [-L paths] [user objects] [gcc libs] [C libs] [gcc libs] crtend.o crtn.o
#
. "$PWD/utils-toolchain.sh"
toolchain_init_pkg glibc
PKG_NAME=glibc-cross
PKG_DEPENDS="gcc-cross-pass1 kernel-headers"

. "$PWD/env.sh"
toolchain_init_vars_build_cross "$PKG_NAME"

#
# '#error "glibc cannot be compiled without optimization".  Optimization is
# required to let GCC do function inlining for linker startup code where
# function call is not allowed.  See glibc FAQ for details on this
#
EXTRA_CFLAGS="$EXTRA_CFLAGS -O2"
#
# XXX: gcc-cross-pass1 is built with --disable-libssp so it does not provide
# stack_chk_guard at the moment, yet the compiler does not fail when supplied
# with -fstack-protector flag, so we need to force disabling the use of ssp at
# the moment.  Note that only a few binaries are affected with libssp off, e.g.
# login, resolv, etc.  Greping for stack-proector in makefile for details.
# Patch from Thomas Petazzoni to buildroot has a good description on this topic
# http://lists.busybox.net/pipermail/buildroot/2014-September/106070.html
#
CONFIGURE_VARS="$CONFIGURE_VARS			\\
	libc_cv_forced_unwind=yes			\\
	libc_cv_ctors_header=yes			\\
	libc_cv_c_cleanup=yes				\\
	libc_cv_ssp=no						\\
	libc_cv_ssp_strong=no				\\
	use_ldconfig=no						\\
"

# Makerules will use prefix when making lib/libc.so, etc. which are ldscripts
# with prefix prepended to referred library names.  When ld was invoked by gcc
# with --sysroot option, it will fail because there is no
# $TOOLCHAIN_DIR/$TOOLCHAIN_DIR/libc.so.6 etc.
CONFIGURE_ARGS="--prefix=						\\
	--build='$TRI_BUILD'						\\
	--host='$TRI_TARGET'						\\
	--with-headers='$TOOLCHAIN_DIR/include'		\\
	--enable-kernel=2.6.32						\\
	--disable-werror							\\
"

staging() {
	local based="$PKG_STAGING_DIR$TOOLCHAIN_DIR"
	local d f df

	build_staging \
		install_root="$based" \
		install

	# strip out path components from ldscript version of these files
	for d in lib usr/lib; do
		for f in libc.so libpthread.so libgcc_s.so libm.so; do
			df="$based/$d/$f"
			if [ -f "$df" -a ! -L "$df" ]; then
				sed -i -e "s,/usr/lib/,,g" -e "s,/lib/,,g" "$df"
			fi
		done
	done
}
