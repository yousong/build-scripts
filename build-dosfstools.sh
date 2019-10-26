#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=dosfstools
PKG_VERSION=4.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="https://github.com/dosfstools/dosfstools/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=07a1050db1a898e9a2e03b0c4569c4bd
PKG_DEPENDS=libiconv
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p1 <<"EOF"
From e18bcc65d5772e518c6496b439bad8a986f7e434 Mon Sep 17 00:00:00 2001
From: Rosen Penev <rosenp@gmail.com>
Date: Thu, 20 Jun 2019 15:18:19 -0700
Subject: [PATCH] configure: Fix iconv check for cross compilation

AC_CHECK_LIB is more friendly towards cross-compilation.

Added check for libiconv_open as that can be used when the libc lacks iconv.
---
 configure.ac | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 07e8703..1b09964 100644
--- a/configure.ac
+++ b/configure.ac
@@ -75,7 +75,8 @@ if test "x$with_udev" != "xno"; then
 		  [true])
 fi
 
-AC_SEARCH_LIBS(iconv_open, iconv)
+AC_CHECK_LIB(iconv, iconv_open)
+AC_CHECK_LIB(iconv, libiconv_open)
 
 # xxd (distributed with vim) is used in the testsuite
 AC_CHECK_PROG([XXD_FOUND], [xxd], [yes])
EOF
}
