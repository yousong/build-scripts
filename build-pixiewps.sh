#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=pixiewps
PKG_VERSION=2016-04-27
PKG_SOURCE_VERSION=1448fff39f01f66151a35f46c2c66739c84119cc
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/wiire/pixiewps/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# make the installation DESTDIR-aware
	patch -p0 <<"EOF"
--- src/Makefile.orig	2016-05-27 09:51:24.636338745 +0800
+++ src/Makefile	2016-05-27 09:51:51.752347399 +0800
@@ -3,9 +3,7 @@ CRYPTO = crypto/sha256.c crypto/md.c cry
 TARGET = pixiewps
 CRYPTO = crypto/sha256.c crypto/md.c crypto/md_wrap.c
 SOURCE = $(TARGET).c random_r.c $(CRYPTO)
-PREFIX = $(DESTDIR)/usr
 BINDIR = $(PREFIX)/bin
-LOCDIR = $(PREFIX)/local/bin
 
 all:
 	$(CC) $(CCFLAGS) -o $(TARGET) $(SOURCE)
@@ -14,13 +13,12 @@ debug:
 	$(CC) $(CCFLAGS) -DDEBUG -o $(TARGET) $(SOURCE)
 
 install:
-	rm -f $(BINDIR)/$(TARGET)
-	rm -f $(LOCDIR)/$(TARGET)
-	install -d $(LOCDIR)
-	install -m 755 $(TARGET) $(LOCDIR)
+	rm -f $(DESTDIR)$(BINDIR)/$(TARGET)
+	install -d $(DESTDIR)$(BINDIR)
+	install -m 755 $(TARGET) $(DESTDIR)$(BINDIR)
 
 uninstall:
-	rm $(LOCDIR)/$(TARGET)
+	rm $(BINDIR)/$(TARGET)
 
 clean:
 	rm -f $(TARGET)
EOF
}

configure() {
	true
}

MAKE_ARGS+=(
	-C "$PKG_SOURCE_DIR/src"
	PREFIX="$INSTALL_PREFIX"
)
