#!/bin/sh -e
#
# Copyright 2016-2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=wget
PKG_VERSION=1.19
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/wget/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1814393c5955a6148ff6d82c4a9e3c21
PKG_DEPENDS='libiconv openssl pcre zlib'

PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# The problem is that I build my own copy of wget and its dependencies and
	# install them into a non-standard location. The build system of wget
	# incorrectly thought that libtool was used and specified the library
	# location with -R which gcc did not understand and erred. 
	#
	# See
	#  - Link failed caused by bad linker option -R,
	#    https://savannah.gnu.org/bugs/?50260
	#  - 5.4.1 The LT_INIT macro, libtool manual
	#
	patch -p0 <<"EOF"
--- configure.ac.orig	2017-02-09 11:22:32.868281297 +0800
+++ configure.ac	2017-02-09 11:22:34.620281846 +0800
@@ -168,6 +168,7 @@ dnl We want these before the checks, so
 test -z "$CFLAGS"  && CFLAGS= auto_cflags=1
 test -z "$CC" && cc_specified=yes
 
+LT_INIT
 AC_PROG_CC
 AM_PROG_CC_C_O
 AC_AIX
--- src/Makefile.am.orig	2017-02-09 12:00:01.376985054 +0800
+++ src/Makefile.am	2017-02-09 12:00:03.616985755 +0800
@@ -88,8 +88,7 @@ version.c:  $(wget_SOURCES) ../lib/libgn
 	echo 'const char *version_string = "@VERSION@";' >> $@
 	echo 'const char *compilation_string = "'$(COMPILE)'";' \
 	    | $(ESCAPEQUOTE) >> $@
-	echo 'const char *link_string = "'$(CCLD) $(AM_CFLAGS) $(CFLAGS) \
-	$(AM_LDFLAGS) $(LDFLAGS) $(LIBS) $(wget_LDADD)'";' \
+	echo 'const char *link_string = "'$(LINK) $(wget_OBJECTS) $(wget_LDADD) $(LIBS)'";' \
 	    | $(ESCAPEQUOTE) >> $@
 
 css.c: $(srcdir)/css.l
EOF
	# To workaround po/Makefile.in.in version check
	#
	# See autopoint func_compare for the comparison for copy decision was done
	patch -p0 <<"EOF"
--- m4/po.m4.orig	2017-02-09 11:49:43.384791630 +0800
+++ m4/po.m4	2017-02-09 11:49:45.780792380 +0800
@@ -1,4 +1,4 @@
-# po.m4 serial 24 (gettext-0.19)
+# po.m4 serial 0 (gettext-0.19)
 dnl Copyright (C) 1995-2014, 2016 Free Software Foundation, Inc.
 dnl This file is free software; the Free Software Foundation
 dnl gives unlimited permission to copy and/or distribute it,
EOF
}

# Wget defaults to GNU TLS but that requires too many dependencies
CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--disable-silent-rules		\\
	--with-ssl=openssl			\\
"
