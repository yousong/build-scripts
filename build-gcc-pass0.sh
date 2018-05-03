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
		unpack "$BASE_DL_DIR/$file" "$PKG_SOURCE_DIR" "s,^$lib[^/]*,$lib,"
	done

	sed -i'' -e 's,gcc_no_link=yes,gcc_no_link=no,' "$PKG_SOURCE_DIR/libstdc++-v3/configure"
}

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p1 <<"EOF"
From 55b4dacc561d2fc31aba276461e020782b1479c9 Mon Sep 17 00:00:00 2001
From: Yousong Zhou <yszhou4tech@gmail.com>
Date: Thu, 3 May 2018 17:37:04 +0800
Subject: [PATCH] gotools: fix compilation when making cross compiler

libgo is "the runtime support library for the Go programming language.
This library is intended for use with the Go frontend."

gccgo will link target files with libgo.so which depends on libgcc_s.so.1, but
the linker will complain that it cannot find it.  That's because shared libgcc
is not present in the install directory yet.  libgo.so was made without problem
because gcc will emit -lgcc_s when compiled with -shared option.  When gotools
were being made, it was supplied with -static-libgcc thus no link option was
provided.  Check LIBGO in gcc/go/gcc-spec.c for how gccgo make a builtin spec
for linking with libgo.so

- GccgoCrossCompilation, https://github.com/golang/go/wiki/GccgoCrossCompilation
- Cross-building instructions, http://www.eglibc.org/archives/patches/msg00078.html

When 3-pass GCC compilation is used, shared libgcc runtime libraries will be
available after gcc pass2 completed and will meet the gotools link requirement
at gcc pass3
---
 gotools/Makefile.am | 4 +++-
 gotools/Makefile.in | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/gotools/Makefile.am b/gotools/Makefile.am
index fb5db639ef8..2c0468d95af 100644
--- a/gotools/Makefile.am
+++ b/gotools/Makefile.am
@@ -26,6 +26,7 @@ PWD_COMMAND = $${PWDCMD-pwd}
 STAMP = echo timestamp >
 
 libgodir = ../$(target_noncanonical)/libgo
+libgccdir = ../$(target_noncanonical)/libgcc
 LIBGODEP = $(libgodir)/libgo.la
 
 LIBGOTOOL = $(libgodir)/libgotool.a
@@ -41,7 +42,8 @@ GOCFLAGS = $(CFLAGS_FOR_TARGET)
 GOCOMPILE = $(GOCOMPILER) $(GOCFLAGS)
 
 AM_GOCFLAGS = -I $(libgodir)
-AM_LDFLAGS = -L $(libgodir) -L $(libgodir)/.libs
+AM_LDFLAGS = -L $(libgodir) -L $(libgodir)/.libs \
+	-L $(libgccdir) -L $(libgccdir)/.libs -lgcc_s
 GOLINK = $(GOCOMPILER) $(GOCFLAGS) $(AM_GOCFLAGS) $(LDFLAGS) $(AM_LDFLAGS) -o $@
 
 libgosrcdir = $(srcdir)/../libgo/go
diff --git a/gotools/Makefile.in b/gotools/Makefile.in
index 13b13eed286..bcbe4710732 100644
--- a/gotools/Makefile.in
+++ b/gotools/Makefile.in
@@ -263,6 +263,7 @@ mkinstalldirs = $(SHELL) $(toplevel_srcdir)/mkinstalldirs
 PWD_COMMAND = $${PWDCMD-pwd}
 STAMP = echo timestamp >
 libgodir = ../$(target_noncanonical)/libgo
+libgccdir = ../$(target_noncanonical)/libgcc
 LIBGODEP = $(libgodir)/libgo.la
 LIBGOTOOL = $(libgodir)/libgotool.a
 @NATIVE_FALSE@GOCOMPILER = $(GOC)
@@ -271,7 +272,8 @@ LIBGOTOOL = $(libgodir)/libgotool.a
 @NATIVE_TRUE@GOCOMPILER = $(GOC_FOR_TARGET) $(XGCC_FLAGS_FOR_TARGET)
 GOCOMPILE = $(GOCOMPILER) $(GOCFLAGS)
 AM_GOCFLAGS = -I $(libgodir)
-AM_LDFLAGS = -L $(libgodir) -L $(libgodir)/.libs
+AM_LDFLAGS = -L $(libgodir) -L $(libgodir)/.libs \
+	-L $(libgccdir) -L $(libgccdir)/.libs -lgcc_s
 GOLINK = $(GOCOMPILER) $(GOCFLAGS) $(AM_GOCFLAGS) $(LDFLAGS) $(AM_LDFLAGS) -o $@
 libgosrcdir = $(srcdir)/../libgo/go
 cmdsrcdir = $(libgosrcdir)/cmd
-- 
2.16.3
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
