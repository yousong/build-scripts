#!/bin/bash -e
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
toolchain_init_genmake_func

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

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# gccgo will link with libgo.so which depends on libgcc_s.so.1 and the
	# linker will complain it cannot find it.  That's because shared libgcc is
	# not present in the install directory yet.  libgo.so was made without
	# problem because gcc will emit -lgcc_s when compiled with -shared option.
	# When gotools were made, it was supplied with -static-libgcc thus no link
	# option was provided.  Check LIBGO in gcc/go/gcc-spec.c for how gccgo make
	# a builtin spec for linking with libgo.so
	#
	# - GccgoCrossCompilation, https://github.com/golang/go/wiki/GccgoCrossCompilation
	# - Cross-building instructions, http://www.eglibc.org/archives/patches/msg00078.html
	#
	# When 3-pass GCC compilation is used, shared libgcc runtime libraries will
	# be available at after gcc pass2 completed and will meet the gotools link
	# requirement at gcc pass3
	patch -p0 <<"EOF"
--- gotools/Makefile.am.orig	2016-11-01 23:04:22.255894433 +0800
+++ gotools/Makefile.am	2016-11-01 23:05:08.483908905 +0800
@@ -26,6 +26,7 @@ PWD_COMMAND = $${PWDCMD-pwd}
 STAMP = echo timestamp >
 
 libgodir = ../$(target_noncanonical)/libgo
+libgccdir = ../$(target_noncanonical)/libgcc
 LIBGODEP = $(libgodir)/libgo.la
 
 if NATIVE
@@ -38,7 +39,8 @@ endif
 GOCFLAGS = $(CFLAGS_FOR_TARGET)
 GOCOMPILE = $(GOCOMPILER) $(GOCFLAGS)
 
-AM_LDFLAGS = -L $(libgodir) -L $(libgodir)/.libs
+AM_LDFLAGS = -L $(libgodir) -L $(libgodir)/.libs \
+	-L $(libgccdir) -L $(libgccdir)/.libs -lgcc_s
 GOLINK = $(GOCOMPILER) $(GOCFLAGS) $(AM_GOCFLAGS) $(LDFLAGS) $(AM_LDFLAGS) -o $@
 
 cmdsrcdir = $(srcdir)/../libgo/go/cmd
--- gotools/Makefile.in.orig	2016-11-01 23:47:17.352700410 +0800
+++ gotools/Makefile.in	2016-11-01 23:48:08.560716438 +0800
@@ -252,13 +252,15 @@ mkinstalldirs = $(SHELL) $(toplevel_srcd
 PWD_COMMAND = $${PWDCMD-pwd}
 STAMP = echo timestamp >
 libgodir = ../$(target_noncanonical)/libgo
+libgccdir = ../$(target_noncanonical)/libgcc
 LIBGODEP = $(libgodir)/libgo.la
 @NATIVE_FALSE@GOCOMPILER = $(GOC)
 
 # Use the compiler we just built.
 @NATIVE_TRUE@GOCOMPILER = $(GOC_FOR_TARGET) $(XGCC_FLAGS_FOR_TARGET)
 GOCOMPILE = $(GOCOMPILER) $(GOCFLAGS)
-AM_LDFLAGS = -L $(libgodir) -L $(libgodir)/.libs
+AM_LDFLAGS = -L $(libgodir) -L $(libgodir)/.libs \
+	-L $(libgccdir) -L $(libgccdir)/.libs -lgcc_s
 GOLINK = $(GOCOMPILER) $(GOCFLAGS) $(AM_GOCFLAGS) $(LDFLAGS) $(AM_LDFLAGS) -o $@
 cmdsrcdir = $(srcdir)/../libgo/go/cmd
 go_cmd_go_files = \
EOF
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
