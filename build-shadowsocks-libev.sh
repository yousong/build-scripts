#!/bin/sh -e

PKG_NAME=shadowsocks-libev
PKG_VERSION=2.4.5
PKG_SOURCE_VERSION=v2.4.5
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/shadowsocks/$PKG_NAME/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_AUTOCONF_FIXUP=1
PKG_DEPENDS='libcork libev libsodium openssl udns zlib'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# - use libcork, libev, libsodium, libudns built by ourselves
	# - rename libipset to libssipset to avoid collision with ipset and
	# libipset utility for Linux kernel
	# - link with these libraries dynamically
	patch -p0 <<"EOF"
--- Makefile.am.orig	2016-02-21 00:30:26.757755621 +0800
+++ Makefile.am	2016-02-21 00:30:45.785761180 +0800
@@ -1,5 +1,5 @@
 if USE_SYSTEM_SHARED_LIB
-SUBDIRS = libcork libipset src
+SUBDIRS = libipset src
 else
 SUBDIRS = libsodium libcork libipset libudns libev src
 endif
--- libipset/Makefile.am.orig	2016-02-21 01:39:59.311062224 +0800
+++ libipset/Makefile.am	2016-02-21 01:41:30.063088134 +0800
@@ -16,7 +16,7 @@
 # License along with libasyncns. If not, see
 # <http://www.gnu.org/licenses/>.
 
-noinst_LTLIBRARIES = libipset.la
+lib_LTLIBRARIES = libssipset.la
 
 bdd_src = bdd/assignments.c bdd/basics.c bdd/bdd-iterator.c bdd/expanded.c \
 		  bdd/reachable.c bdd/read.c bdd/write.c 
@@ -26,6 +26,5 @@ set_src = set/allocation.c set/inspectio
 		  set/iterator.c set/storage.c
 
-libipset_la_SOURCES = general.c ${bdd_src} ${map_src} ${set_src}
-libipset_la_CFLAGS = -I$(top_srcdir)/libipset/include -I$(top_srcdir)/libcork/include
-
-libipset_la_LDFLAGS = -static
+libssipset_la_SOURCES = general.c ${bdd_src} ${map_src} ${set_src}
+libssipset_la_CFLAGS = -I$(top_srcdir)/libipset/include
+libssipset_la_LIBADD = -lcork
--- src/Makefile.am.orig	2016-02-21 00:31:19.885772784 +0800
+++ src/Makefile.am	2016-02-21 00:33:53.789820703 +0800
@@ -5,19 +5,19 @@ AM_CFLAGS += $(PTHREAD_CFLAGS)
 if !USE_SYSTEM_SHARED_LIB
 AM_CFLAGS += -I$(top_srcdir)/libev
 AM_CFLAGS += -I$(top_srcdir)/libudns
 AM_CFLAGS += -I$(top_srcdir)/libsodium/src/libsodium/include
+AM_CFLAGS += -I$(top_srcdir)/libcork/include
 endif
 AM_CFLAGS += -I$(top_srcdir)/libipset/include
-AM_CFLAGS += -I$(top_srcdir)/libcork/include
 
-SS_COMMON_LIBS = $(top_builddir)/libipset/libipset.la \
+SS_COMMON_LIBS = $(top_builddir)/libipset/libssipset.la \
-                 $(top_builddir)/libcork/libcork.la \
                  $(INET_NTOP_LIB)
 if USE_SYSTEM_SHARED_LIB
-SS_COMMON_LIBS += -lev -lsodium -lm
+SS_COMMON_LIBS += -lev -lsodium -lcork -lm
 else
 SS_COMMON_LIBS += $(top_builddir)/libev/libev.la \
+                  $(top_builddir)/libcork/libcork.la \
                   $(top_builddir)/libsodium/src/libsodium/libsodium.la
 endif
 
 bin_PROGRAMS = ss-local ss-tunnel
EOF
}

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--enable-system-shared-lib		\\
	--disable-static				\\
	--enable-shared					\\
	--disable-silent-rules			\\
"
