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
	# Use LIB<NAME> instead of LTLIB when LT_INIT is not used in configure.ac
	#
	# See
	#  - Link failed caused by bad linker option -R,
	#    https://savannah.gnu.org/bugs/?50260
	#  - 13.11 Searching for Libraries,
	#    https://www.gnu.org/software/gnulib/manual/html_node/Searching-for-Libraries.html
	#
	patch -p0 <<"EOF"
--- src/Makefile.am.orig	2017-02-10 19:16:33.024224909 +0800
+++ src/Makefile.am	2017-02-10 19:19:25.620278930 +0800
@@ -65,8 +65,8 @@ nodist_wget_SOURCES = version.c
 EXTRA_wget_SOURCES = iri.c
 LDADD = $(LIBOBJS) ../lib/libgnu.a $(GETADDRINFO_LIB) $(HOSTENT_LIB)\
  $(INET_NTOP_LIB) $(LIBSOCKET) $(LIB_CLOCK_GETTIME) $(LIB_CRYPTO)\
- $(LIB_NANOSLEEP) $(LIB_POSIX_SPAWN) $(LIB_SELECT) $(LTLIBICONV) $(LTLIBINTL)\
- $(LTLIBTHREAD) $(LTLIBUNISTRING) $(SERVENT_LIB)
+ $(LIB_NANOSLEEP) $(LIB_POSIX_SPAWN) $(LIB_SELECT) $(LIBICONV) $(LIBINTL)\
+ $(LIBTHREAD) $(LIBUNISTRING) $(SERVENT_LIB)
 AM_CPPFLAGS = -I$(top_builddir)/lib -I$(top_srcdir)/lib
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
