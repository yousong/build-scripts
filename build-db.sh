#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=db
PKG_VERSION=5.3.28
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://download.oracle.com/berkeley-db/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b99454564d5b4479750567031d66fe24

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# taken from macports db53
	patch -p0 <<"EOF"
--- src/dbinc/atomic.h.orig	2012-02-29 19:48:38.000000000 +0100
+++ src/dbinc/atomic.h	2012-05-04 22:39:32.000000000 +0200
@@ -144,7 +144,7 @@ typedef LONG volatile *interlocked_val;
 #define	atomic_inc(env, p)	__atomic_inc(p)
 #define	atomic_dec(env, p)	__atomic_dec(p)
 #define	atomic_compare_exchange(env, p, o, n)	\
-	__atomic_compare_exchange((p), (o), (n))
+	__atomic_compare_exchange_db((p), (o), (n))
 static inline int __atomic_inc(db_atomic_t *p)
 {
 	int	temp;
@@ -176,7 +176,7 @@ static inline int __atomic_dec(db_atomic
  * http://gcc.gnu.org/onlinedocs/gcc-4.1.0/gcc/Atomic-Builtins.html
  * which configure could be changed to use.
  */
-static inline int __atomic_compare_exchange(
+static inline int __atomic_compare_exchange_db(
 	db_atomic_t *p, atomic_value_t oldval, atomic_value_t newval)
 {
 	atomic_value_t was;
EOF
}

CONFIGURE_PATH="$PKG_SOURCE_DIR/build_unix"
CONFIGURE_CMD="$PKG_SOURCE_DIR/dist/configure"
# --enable-dbm, is for python module dbm
CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--disable-tcl					\\
	--disable-java					\\
	--enable-compat185				\\
	--enable-dbm					\\
"

MAKE_ARGS="							\\
	-C '$PKG_SOURCE_DIR/build_unix'	\\
"
MAKE_VARS="												\\
	docdir='$INSTALL_PREFIX/share/db-$PKG_VERSION/docs'	\\
"
