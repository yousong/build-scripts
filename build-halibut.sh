#!/bin/sh -e

PKG_NAME=halibut
PKG_VERSION=1.1
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.chiark.greenend.org.uk/~sgtatham/halibut/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=bd2821b7a124b4b9aa356e12f09c4cb2

. "$PWD/env.sh"

configure() {
	true
}

MAKE_VARS="LFLAGS='$EXTRA_LDFLAGS' prefix='$INSTALL_PREFIX'"

do_patch() {
	cd "$PKG_BUILD_DIR"
	patch -p1 <<"EOF"
--- a/doc/Makefile.orig	2015-12-14 10:25:00.000000000 +0800
+++ b/doc/Makefile	2015-12-14 10:25:02.000000000 +0800
@@ -1,4 +1,4 @@
-mandir=$(prefix)/man
+mandir=$(prefix)/share/man
 man1dir=$(mandir)/man1
 
 CHAPTERS := $(SITE) blurb intro running input output licence manpage index
@@ -17,7 +17,8 @@ halibut.1: manpage.but
 	$(HALIBUT) --man=halibut.1 manpage.but
 
 install:
-	$(INSTALL) -m 644 halibut.1 $(man1dir)/halibut.1
+	$(INSTALL) -m 755 -d $(DESTDIR)$(man1dir)
+	$(INSTALL) -m 644 halibut.1 $(DESTDIR)$(man1dir)/halibut.1
 
 clean:
 	rm -f *.html *.txt *.hlp *.cnt *.1 *.info* *.ps *.pdf *.hh* *.chm
--- a/Makefile.orig	2015-12-14 10:23:39.000000000 +0800
+++ b/Makefile	2015-12-14 10:23:48.000000000 +0800
@@ -45,7 +45,7 @@ LIBS += -lefence
 
 all install:
 	@test -d $(BUILDDIR) || mkdir $(BUILDDIR)
-	@$(MAKE) -C $(BUILDDIR) -f ../Makefile $@ REALBUILD=yes
+	@$(MAKE) -C $(BUILDDIR) -f ../Makefile $@ REALBUILD=yes prefix="$(prefix)"
 
 spotless: topclean
 	@test -d $(BUILDDIR) || mkdir $(BUILDDIR)
@@ -77,6 +77,7 @@ LIBS += -lefence
 endif

 all: halibut
+	$(MAKE) -C ../doc prefix="$(prefix)"

 SRC := ../
 
@@ -116,7 +116,8 @@ clean::
 	rm -f *.o halibut core
 
 install:
-	$(INSTALL) -m 755 halibut $(bindir)/halibut
+	$(INSTALL) -m 755 -d $(DESTDIR)$(bindir)
+	$(INSTALL) -m 755 halibut $(DESTDIR)$(bindir)/halibut
 	$(MAKE) -C ../doc install prefix="$(prefix)" INSTALL="$(INSTALL)"
 
 FORCE: # phony target to force version.o to be rebuilt every time
--- a/charset/Makefile.orig	2015-12-14 10:23:39.000000000 +0800
+++ b/charset/Makefile	2015-12-14 10:23:48.000000000 +0800
@@ -215,6 +215,7 @@
 	$(LIBCHARSET_OBJDIR)sbcsdat.c
 	$(CC) $(CFLAGS) $(MD) -c -o $@ $<
 
+$(LIBCHARSET_OBJS): $(LIBCHARSET_OBJDIR)sbcsdat.c $(LIBCHARSET_OBJDIR)sbcsdat.h
 $(LIBCHARSET_OBJDIR)sbcsdat.c $(LIBCHARSET_OBJDIR)sbcsdat.h: \
 	$(LIBCHARSET_SRCDIR)sbcs.dat \
 	$(LIBCHARSET_SRCDIR)sbcsgen.pl
EOF
}

