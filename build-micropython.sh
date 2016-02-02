#!/bin/sh -e
#
# Requires @libffi
#
PKG_NAME=micropython
PKG_VERSION=2016-01-05
PKG_SOURCE_VERSION=67f40fb237d5c2fa5a8b9604e76a99716492a44a
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/micropython/micropython/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libffi'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_BUILD_DIR"

	patch -p0 <<"EOF"
--- unix/Makefile.orig	2016-01-06 16:16:35.895581987 +0800
+++ unix/Makefile	2016-01-06 16:19:23.015635295 +0800
@@ -149,14 +149,14 @@ test: $(PROG) ../tests/run-tests
 
 # install micropython in /usr/local/bin
 TARGET = micropython
-PREFIX = $(DESTDIR)/usr/local
+PREFIX = /usr/local
 BINDIR = $(PREFIX)/bin
 PIPSRC = ../tools/pip-micropython
 PIPTARGET = pip-micropython
 
 install: micropython
-	install -D $(TARGET) $(BINDIR)/$(TARGET)
-	install -D $(PIPSRC) $(BINDIR)/$(PIPTARGET)
+	install -D $(TARGET) $(DESTDIR)$(BINDIR)/$(TARGET)
+	install -D $(PIPSRC) $(DESTDIR)$(BINDIR)/$(PIPTARGET)
 
 # uninstall micropython
 uninstall:
EOF
}

configure() {
	true
}

MAKE_ENVS="												\\
	CFLAGS_EXTRA='$EXTRA_CFLAGS -fno-strict-aliasing'	\\
	LDFLAGS_EXTRA='$EXTRA_LDFLAGS'						\\
"
MAKE_ARGS="-C unix"
MAKE_VARS="V=1 PREFIX=$INSTALL_PREFIX"
