#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=reaver-wps-fork-t6x
PKG_VERSION=2016-04-26
PKG_SOURCE_VERSION=ff99a969a8b8816f58cec6c4a3c618530df49cf5
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/t6x/reaver-wps-fork-t6x/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='libpcap sqlite'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# make the installation DESTDIR-aware
	patch -p0 <<"EOF"
--- src/Makefile.in.orig	2016-05-27 09:24:22.603830706 +0800
+++ src/Makefile.in	2016-05-27 09:25:19.427850582 +0800
@@ -93,10 +93,11 @@ globule.o:
 	$(CC) $(CFLAGS) globule.c -c 
 
 install: cleanbin
-	if [ ! -d $(CONFDIR) ]; then mkdir -p $(CONFDIR); fi
-	if [ ! -e $(CONFDIR)/reaver.db ]; then cp reaver.db $(CONFDIR)/reaver.db && chmod -R a+rw $(CONFDIR); fi
-	if [ -e wash ]; then cp wash @bindir@/wash; fi
-	if [ -e reaver ]; then cp reaver @bindir@/reaver; fi
+	if [ ! -d $(DESTDIR)@bindir@ ]; then mkdir -p $(DESTDIR)@bindir@; fi
+	if [ ! -d $(DESTDIR)$(CONFDIR) ]; then mkdir -p $(DESTDIR)$(CONFDIR); fi
+	if [ ! -e $(DESTDIR)$(CONFDIR)/reaver.db ]; then cp reaver.db $(DESTDIR)$(CONFDIR)/reaver.db && chmod -R a+rw $(DESTDIR)$(CONFDIR); fi
+	if [ -e wash ]; then cp wash $(DESTDIR)@bindir@/wash; fi
+	if [ -e reaver ]; then cp reaver $(DESTDIR)@bindir@/reaver; fi
 
 clean:
 	rm -f *~ *.o reaver wash
EOF
}

CONFIGURE_PATH="$PKG_SOURCE_DIR/src"
CONFIGURE_CMD="$PKG_SOURCE_DIR/src/configure"

MAKE_ARGS="						\\
	-C '$PKG_SOURCE_DIR/src'	\\
"
