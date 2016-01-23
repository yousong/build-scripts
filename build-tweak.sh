#!/bin/sh -e
#
# tweak depends on @halibut to make docs
#
PKG_NAME=tweak
PKG_VERSION=2015-04-22
PKG_SOURCE_VERSION=18448721678b2169a4e3cc03c048f8fb85ee7776
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="http://tartarus.org/~simon-git/gitweb/?p=tweak.git;a=snapshot;h=$PKG_SOURCE_VERSION;sf=tgz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS='halibut ncurses'

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS="LFLAGS='$EXTRA_LDFLAGS' PREFIX='$PKG_STAGING_DIR$INSTALL_PREFIX'"

do_patch() {
	cd "$PKG_BUILD_DIR"
	patch -p1 <<"EOF"
--- a/Makefile.orig	2015-12-14 11:13:57.000000000 +0800
+++ b/Makefile	2015-12-14 11:17:00.000000000 +0800
@@ -24,7 +24,7 @@ LIBS := 
 
 PREFIX=$(DESTDIR)/usr/local
 BINDIR=$(PREFIX)/bin
-MANDIR=$(PREFIX)/man/man1
+MANDIR=$(PREFIX)/share/man/man1
 
 TWEAK := main.o keytab.o actions.o search.o rcfile.o buffer.o btree.o
 
@@ -38,13 +38,10 @@ LIBS += -lncurses
 TWEAK += curses.o
 endif
 
-.c.o:
-	$(CC) $(CFLAGS) $*.c
-
 all: tweak tweak.1 btree.html
 
 tweak:	$(TWEAK)
-	$(LINK) -o tweak $(TWEAK) $(LIBS)
+	$(LINK) $(LFLAGS) -o tweak $(TWEAK) $(LIBS)
 
 tweak.1:  manpage.but
 	halibut --man=$@ $<
EOF
}
