#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=ctags
PKG_VERSION=5.8
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/ctags/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=c00f82ecdcc357434731913e5b48630d

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# 6 How to Use Variables, GNU make manual
	#
	#	A variable name may be any sequence of characters not containing ‘:’,
	#	‘#’, ‘=’, or leading or trailing whitespace. However, variable names
	#	containing characters other than letters, numbers, and underscores
	#	should be avoided, as they may be given special meanings in the future,
	#	and with some shells they cannot be passed through the environment to a
	#	sub-make
	#
	# Allow '/' to be valid lexcial element of identifier
	#
	patch -p0 <<"EOF"
--- make.c.orig	2016-06-01 20:06:46.847104986 +0800
+++ make.c	2016-06-01 20:07:02.839109892 +0800
@@ -70,7 +70,7 @@ static int skipToNonWhite (void)
 
 static boolean isIdentifier (int c)
 {
-	return (boolean)(c != '\0' && (isalnum (c)  ||  strchr (".-_", c) != NULL));
+	return (boolean)(c != '\0' && (isalnum (c)  ||  strchr (".-_/", c) != NULL));
 }
 
 static void readIdentifier (const int first, vString *const id)
--- Makefile.in.orig	2016-06-01 20:09:20.911155981 +0800
+++ Makefile.in	2016-06-01 20:09:29.703156974 +0800
@@ -85,12 +85,12 @@ EMAN	= $(ETAGS_PROG).$(manext)
 #
 CTAGS_EXEC	= $(CTAGS_PROG)$(EXEEXT)
 ETAGS_EXEC	= $(ETAGS_PROG)$(EXEEXT)
-DEST_CTAGS	= $(bindir)/$(CTAGS_EXEC)
-DEST_ETAGS	= $(bindir)/$(ETAGS_EXEC)
-DEST_READ_LIB	= $(libdir)/$(READ_LIB)
-DEST_READ_INC	= $(incdir)/$(READ_INC)
-DEST_CMAN	= $(man1dir)/$(CMAN)
-DEST_EMAN	= $(man1dir)/$(EMAN)
+DEST_CTAGS	= $(DESTDIR)$(bindir)/$(CTAGS_EXEC)
+DEST_ETAGS	= $(DESTDIR)$(bindir)/$(ETAGS_EXEC)
+DEST_READ_LIB	= $(DESTDIR)$(libdir)/$(READ_LIB)
+DEST_READ_INC	= $(DESTDIR)$(incdir)/$(READ_INC)
+DEST_CMAN	= $(DESTDIR)$(man1dir)/$(CMAN)
+DEST_EMAN	= $(DESTDIR)$(man1dir)/$(EMAN)
 
 #
 # primary rules
@@ -139,6 +139,7 @@ install-ebin: $(DEST_ETAGS)
 install-lib: $(DEST_READ_LIB) $(DEST_READ_INC)
 
 $(DEST_CTAGS): $(CTAGS_EXEC) $(bindir) FORCE
+	mkdir -p "`dirname $@`"
 	$(INSTALL_PROG) $(CTAGS_EXEC) $@  &&  chmod 755 $@
 
 $(DEST_ETAGS):
@@ -154,6 +155,7 @@ install-cman: $(DEST_CMAN)
 install-eman: $(DEST_EMAN)
 
 $(DEST_CMAN): $(man1dir) $(MANPAGE) FORCE
+	- mkdir -p "`dirname $@`"
 	- $(INSTALL_DATA) $(srcdir)/$(MANPAGE) $@  &&  chmod 644 $@
 
 $(DEST_EMAN):
@@ -165,9 +167,11 @@ $(DEST_EMAN):
 # install the library
 #
 $(DEST_READ_LIB): $(READ_LIB) $(libdir) FORCE
+	- mkdir -p "`dirname $@`"
 	$(INSTALL_PROG) $(READ_LIB) $@  &&  chmod 644 $@
 
 $(DEST_READ_INC): $(READ_INC) $(incdir) FORCE
+	- mkdir -p "`dirname $@`"
 	$(INSTALL_PROG) $(READ_INC) $@  &&  chmod 644 $@
 
 
EOF
}
