#!/bin/bash -e
#
# Copyright 2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=pigz
PKG_VERSION=2.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://zlib.net/pigz/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=def2f6e19d9d8231445adc1349d346df

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- Makefile.orig	2020-08-26 13:06:46.170556950 +0800
+++ Makefile	2020-08-26 13:06:47.721552885 +0800
@@ -11,6 +11,11 @@ pigz: pigz.o yarn.o try.o $(ZOP)
 	$(CC) $(LDFLAGS) -o pigz pigz.o yarn.o try.o $(ZOP) $(LIBS)
 	ln -f pigz unpigz
 
+install:
+	install -d $(DESTDIR)$(PREFIX)/bin
+	install -m 0755 pigz $(DESTDIR)$(PREFIX)/bin
+	ln -s pigz $(DESTDIR)$(PREFIX)/bin/unpigz
+
 pigz.o: pigz.c yarn.h try.h $(ZOPFLI)deflate.h $(ZOPFLI)util.h
 
 yarn.o: yarn.c yarn.h
EOF
}

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)
