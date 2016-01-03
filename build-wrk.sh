#!/bin/sh -e
#
PKG_NAME=wrk
PKG_VERSION=2015-11-04
PKG_SOURCE_VERSION=03dc368674402f4b26a862f941f29887d06fd564
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/wg/wrk/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_CMAKE=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_BUILD_DIR"

	# $3 (implicit-install-check) for APR_FIND_APR should be set to 1
	patch -p0 <<"EOF"
--- Makefile.orig	2016-01-04 01:30:30.640813279 +0800
+++ Makefile	2016-01-04 01:34:22.872885305 +0800
@@ -1,4 +1,4 @@
-CFLAGS  := -std=c99 -Wall -O2 -D_REENTRANT
+CFLAGS  += -std=c99 -Wall -O2 -D_REENTRANT
 LIBS    := -lpthread -lm -lcrypto -lssl
 
 TARGET  := $(shell uname -s | tr '[A-Z]' '[a-z]' 2>/dev/null || echo unknown)
@@ -56,6 +56,10 @@ $(LDIR)/libluajit.a:
 	@echo Building LuaJIT...
 	@$(MAKE) -C $(LDIR) BUILDMODE=static
 
+install:
+	mkdir -p $(DESTDIR)$(PREFIX)/bin
+	install -m 0755 wrk $(DESTDIR)$(PREFIX)/bin
+
 .PHONY: all clean
 .SUFFIXES:
 .SUFFIXES: .c .o .lua
EOF
}
configure() {
	true
}

MAKE_VARS="PREFIX=$INSTALL_PREFIX"
