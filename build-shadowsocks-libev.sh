#!/bin/bash -e
#
# Copyright 2016-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=shadowsocks-libev
PKG_VERSION=3.3.5
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/shadowsocks/$PKG_NAME/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=891392c245ab4702b70f0053bd3eec6b
PKG_AUTOCONF_FIXUP=1
PKG_DEPENDS='c-ares libcork libev libsodium mbedtls pcre udns'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# - use libcork, libev, libsodium, libudns built by ourselves
	# - rename libipset to libssipset to avoid collision with ipset and
	# libipset utility for Linux kernel
	# - link with these libraries dynamically
	patch -p0 <<"EOF"
--- configure.ac.orig	2017-05-12 22:31:16.788199538 +0800
+++ configure.ac	2017-05-12 22:32:40.360225698 +0800
@@ -234,7 +234,9 @@ AC_CONFIG_FILES([shadowsocks-libev.pc
 
 AM_COND_IF([USE_SYSTEM_SHARED_LIB],
 		   [AC_DEFINE([USE_SYSTEM_SHARED_LIB], [1], [Define if use system shared lib.])],
-		   [AC_CONFIG_FILES([libbloom/Makefile libcork/Makefile libipset/Makefile])])
+		   [AC_CONFIG_FILES([libcork/Makefile])])
+
+AC_CONFIG_FILES([libbloom/Makefile libipset/Makefile])
 
 AM_COND_IF([ENABLE_DOCUMENTATION],
   [AC_CONFIG_FILES([doc/Makefile])
--- Makefile.am.orig	2017-05-12 22:42:11.136404343 +0800
+++ Makefile.am	2017-05-12 22:42:51.760417057 +0800
@@ -1,7 +1,6 @@
-if USE_SYSTEM_SHARED_LIB
-SUBDIRS = src
-else
-SUBDIRS = libcork libipset libbloom src
+SUBDIRS = libipset libbloom src
+if !USE_SYSTEM_SHARED_LIB
+SUBDIRS += libcork
 endif
 
 if ENABLE_DOCUMENTATION
--- src/Makefile.am.orig	2017-05-12 22:33:17.816237421 +0800
+++ src/Makefile.am	2017-05-12 22:40:08.844366069 +0800
@@ -2,20 +2,21 @@ VERSION_INFO = 2:0:0
 
 AM_CFLAGS = -g -O2 -Wall -Werror -Wno-deprecated-declarations -fno-strict-aliasing -std=gnu99 -D_GNU_SOURCE
 AM_CFLAGS += $(PTHREAD_CFLAGS)
-if !USE_SYSTEM_SHARED_LIB
 AM_CFLAGS += -I$(top_srcdir)/libbloom
 AM_CFLAGS += -I$(top_srcdir)/libipset/include
+if !USE_SYSTEM_SHARED_LIB
 AM_CFLAGS += -I$(top_srcdir)/libcork/include
 endif
 AM_CFLAGS += $(LIBPCRE_CFLAGS)
 
 SS_COMMON_LIBS = $(INET_NTOP_LIB) $(LIBPCRE_LIBS)
-if !USE_SYSTEM_SHARED_LIB
 SS_COMMON_LIBS += $(top_builddir)/libbloom/libbloom.la \
-                  $(top_builddir)/libipset/libipset.la \
-                  $(top_builddir)/libcork/libcork.la
+                  $(top_builddir)/libipset/libssipset.la
+
+if !USE_SYSTEM_SHARED_LIB
+SS_COMMON_LIBS += $(top_builddir)/libcork/libcork.la
 else
-SS_COMMON_LIBS += -lbloom -lcork -lcorkipset
+SS_COMMON_LIBS += -lcork
 endif
 SS_COMMON_LIBS += -lev -lsodium -lm
 
--- libipset/Makefile.am.orig	2017-05-12 22:46:07.376478286 +0800
+++ libipset/Makefile.am	2017-05-12 22:46:36.300487336 +0800
@@ -1,4 +1,4 @@
-noinst_LTLIBRARIES = libipset.la
+noinst_LTLIBRARIES = libssipset.la
 
 bdd_src = src/libipset/bdd/assignments.c \
 		  src/libipset/bdd/basics.c \
@@ -21,7 +21,7 @@ set_src = src/libipset/set/allocation.c
 		  src/libipset/set/iterator.c \
 		  src/libipset/set/storage.c
 
-libipset_la_SOURCES = src/libipset/general.c ${bdd_src} ${map_src} ${set_src}
-libipset_la_CFLAGS = -I$(top_srcdir)/libipset/include -I$(top_srcdir)/libcork/include
+libssipset_la_SOURCES = src/libipset/general.c ${bdd_src} ${map_src} ${set_src}
+libssipset_la_CFLAGS = -I$(top_srcdir)/libipset/include -I$(top_srcdir)/libcork/include
 
-libipset_la_LDFLAGS = -static
+libssipset_la_LDFLAGS = -static
--- src/acl.c.orig	2017-05-12 22:54:53.424642931 +0800
+++ src/acl.c	2017-05-12 22:54:57.152644096 +0800
@@ -26,11 +26,7 @@
 
 #include <ctype.h>
 
-#ifdef USE_SYSTEM_SHARED_LIB
-#include <libcorkipset/ipset.h>
-#else
 #include <ipset/ipset.h>
-#endif
 
 #include "rule.h"
 #include "utils.h"
EOF
}

# shared and static libraries cannot be both disabled.  It's written in the
# generated configure script
CONFIGURE_ARGS+=(
	--enable-system-shared-lib
	--disable-silent-rules
	--disable-documentation
	--disable-shared
)
