#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Example run
#
#	http_load -parallel 10 -seconds 5 <(echo https://localhost:8080/hello)
#
# Well, looks like the result is too bad compared to what ab does.
#
PKG_NAME=http_load
PKG_VERSION=14aug2014
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://acme.com/software/http_load/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=44514f4f1f2a4791be6f2e003618ae99
PKG_DEPENDS='openssl'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# $3 (implicit-install-check) for APR_FIND_APR should be set to 1
	patch -p0 <<"EOF"
--- Makefile.orig	2016-01-03 02:43:12.415137175 +0800
+++ Makefile	2016-01-03 02:47:28.359216463 +0800
@@ -9,17 +9,17 @@
 # http://www.openssl.org/  Make sure the SSL_TREE definition points to the
 # tree with your OpenSSL installation - depending on how you installed it,
 # it may be in /usr/local instead of /usr/local/ssl.
-#SSL_TREE =	/usr/local/ssl
-#SSL_DEFS =	-DUSE_SSL
-#SSL_INC =	-I$(SSL_TREE)/include
-#SSL_LIBS =	-L$(SSL_TREE)/lib -lssl -lcrypto
+SSL_TREE =	$(PREFIX)
+SSL_DEFS =	-DUSE_SSL
+SSL_INC =	-I$(SSL_TREE)/include
+SSL_LIBS =	-L$(SSL_TREE)/lib -lssl -lcrypto
 
 
-BINDIR =	/usr/local/bin
-MANDIR =	/usr/local/man/man1
+BINDIR =	$(PREFIX)/bin
+MANDIR =	$(PREFIX)/share/man/man1
 CC =		cc
-CFLAGS =	-O $(SRANDOM_DEFS) $(SSL_DEFS) $(SSL_INC) -ansi -pedantic -U__STRICT_ANSI__ -Wall -Wpointer-arith -Wshadow -Wcast-qual -Wcast-align -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls -Wno-long-long
-LDFLAGS =	-s $(SSL_LIBS) $(SYSV_LIBS)
+CFLAGS +=	-O $(SRANDOM_DEFS) $(SSL_DEFS) $(SSL_INC) -ansi -pedantic -U__STRICT_ANSI__ -Wall -Wpointer-arith -Wshadow -Wcast-qual -Wcast-align -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls -Wno-long-long
+LDFLAGS +=	-s $(SSL_LIBS) $(SYSV_LIBS)
 
 all:		http_load
 
@@ -30,10 +30,12 @@ timers.o:	timers.c timers.h
 	$(CC) $(CFLAGS) -c timers.c
 
 install:	all
-	rm -f $(BINDIR)/http_load
-	cp http_load $(BINDIR)
-	rm -f $(MANDIR)/http_load.1
-	cp http_load.1 $(MANDIR)
+	mkdir -p $(DESTDIR)$(BINDIR)
+	rm -f $(DESTDIR)$(BINDIR)/http_load
+	cp http_load $(DESTDIR)$(BINDIR)
+	mkdir -p $(DESTDIR)$(MANDIR)
+	rm -f $(DESTDIR)$(MANDIR)/http_load.1
+	cp http_load.1 $(DESTDIR)$(MANDIR)
 
 clean:
 	rm -f http_load *.o core core.* *.core
EOF
}

configure() {
	true
}

MAKE_VARS="PREFIX=$INSTALL_PREFIX"
