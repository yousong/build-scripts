#!/bin/sh -e
#
# GNU ar provided by binutils is different from BSD ar (/usr/bin/ar) present in
# Mac OS X.  From the output of `/usr/bin/ar -vt lib/libncursesw.a' where
# `libncursesw.a' was generated with GNU ar, it seems that clang can only work
# with those made by /usr/bin/ar
#
# - http://stackoverflow.com/questions/22107616/static-library-built-for-archive-which-is-not-the-architecture-being-linked-x86
#
. "$PWD/utils-toolchain.sh"
toolchain_init_pkg binutils
PKG_NAME=binutils-cross
PKG_PLATFORM=linux
PKG_DEPENDS='binutils-pass0'

. "$PWD/env.sh"
toolchain_init_vars_build_cross "$PKG_NAME"

# --disable-initfini-array is a configure option of ld.  It was default off for
# cross build before 2.27 and was turned into a default on option since
# 2015-12-02 [1].  It has to be disabled for at least glibc 2.24 because bad
# values may creep into .init_array causing segfault at program startup time.
#
# See binutils/ld/scripttempl/elf.sc and glibc/elf/so{init,fini}.c for details.
# glibc uses ldscript emitted by command ld --verbose and stores it as
# shlib.lds at build time
#
# [1] Make --enable-initfini-array the default,
#     https://sourceware.org/ml/binutils-cvs/2015-12/msg00016.html
CONFIGURE_ARGS="$CONFIGURE_ARGS			\\
	--with-sysroot='$TOOLCHAIN_DIR'		\\
	--build='$TRI_BUILD'				\\
	--host='$TRI_HOST'					\\
	--target='$TRI_TARGET'				\\
	--enable-plugins					\\
	--disable-multilib					\\
	--disable-werror					\\
	--disable-nls						\\
	--disable-sim						\\
	--disable-gdb						\\
	--disable-initfini-array			\\
"

staging_post() {
	local base="$PKG_STAGING_DIR$TOOLCHAIN_DIR"

	# ld will look for libc.so.6, etc. in $base/$TRI_TARGET/lib which will be
	# installed from glibc into $base/lib
	#
	# gcc-pass2 requires the existence of $base/usr/include
	mkdir -p "$base/usr/include"
	ln -sf 'lib' "$base/lib64"
	ln -sf '../lib' "$base/$TRI_TARGET/lib64"
	ln -sf '../lib' "$base/$TRI_TARGET/lib"
}
