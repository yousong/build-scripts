#!/bin/sh -e

PKG_NAME=rtmpdump
PKG_VERSION=2.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tgz"
PKG_SOURCE_URL="http://rtmpdump.mplayerhq.hu/download/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=eb961f31cd55f0acf5aad1a7b900ef59

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_BUILD_DIR"

	patch -p0 <<"EOF"
--- Makefile.orig	2015-12-23 12:05:04.901000015 +0800
+++ Makefile	2015-12-23 12:05:09.890000016 +0800
@@ -25,7 +25,7 @@ LDFLAGS=-Wall $(XLDFLAGS)
 
 bindir=$(prefix)/bin
 sbindir=$(prefix)/sbin
-mandir=$(prefix)/man
+mandir=$(prefix)/share/man
 
 BINDIR=$(DESTDIR)$(bindir)
 SBINDIR=$(DESTDIR)$(sbindir)
--- librtmp/Makefile.orig	2015-12-23 12:05:04.901000015 +0800
+++ librtmp/Makefile	2015-12-23 12:05:09.890000016 +0800
@@ -44,7 +44,7 @@ LDFLAGS=-Wall $(XLDFLAGS)
 incdir=$(prefix)/include/librtmp
 bindir=$(prefix)/bin
 libdir=$(prefix)/lib
-mandir=$(prefix)/man
+mandir=$(prefix)/share/man
 BINDIR=$(DESTDIR)$(bindir)
 INCDIR=$(DESTDIR)$(incdir)
 LIBDIR=$(DESTDIR)$(libdir)
@@ -84,6 +84,7 @@ LDFLAGS=-Wall $(XLDFLAGS)
 	cp librtmp.3 $(MANDIR)/man3
 
 install_so.0:	librtmp.so.0
+	-mkdir -p $(LIBDIR)
 	cp librtmp.so.0 $(LIBDIR)
 	cd $(LIBDIR); ln -sf librtmp.so.0 librtmp.so
 
EOF
}

configure() {
	true
}

MAKE_VARS="					\\
	prefix=$INSTALL_PREFIX	\\
"
