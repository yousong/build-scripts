#!/bin/bash -e
#
# Copyright 2016-2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=wrk
PKG_VERSION=4.1.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/wg/wrk/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='openssl'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
--- Makefile.orig	2016-01-04 01:30:30.640813279 +0800
+++ Makefile	2016-01-04 01:34:22.872885305 +0800
@@ -102,6 +102,10 @@ $(LDIR)/libluajit.a:
 
 # ------------
 
+install:
+	mkdir -p $(DESTDIR)$(PREFIX)/bin
+	install -m 0755 wrk $(DESTDIR)$(PREFIX)/bin
+
 .PHONY: all clean
 .PHONY: $(ODIR)/version.o
 
EOF
}

configure() {
	true
}

#	WITH_LUAJIT="$INSTALL_PREFIX"
MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
	WITH_OPENSSL="$INSTALL_PREFIX"
)
