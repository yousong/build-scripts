#!/bin/sh -e
#
PKG_NAME=bzip2
PKG_VERSION=1.0.6
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.bzip.org/1.0.6/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=00b516f4704d4a7cb50a1d97e6e8e15b

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_BUILD_DIR"

	# 0. Allow CFLAGS and LDFLAGS from environment variable
	# 1. Build both shared and static library in one Makefile
	# 2. Allow specifying mandir= on command line
	# 3. Symlink in a relative path way
	patch -p0 <<"EOF"
--- Makefile.orig	2016-01-21 20:29:09.977960018 +0800
+++ Makefile	2016-01-21 20:32:57.682029995 +0800
@@ -18,13 +18,13 @@ SHELL=/bin/sh
 CC=gcc
 AR=ar
 RANLIB=ranlib
-LDFLAGS=
 
 BIGFILES=-D_FILE_OFFSET_BITS=64
-CFLAGS=-Wall -Winline -O2 -g $(BIGFILES)
+CFLAGS+=-Wall -Winline -O2 -g $(BIGFILES)
 
 # Where you want it installed when you do 'make install'
 PREFIX=/usr/local
+mandir:=$(PREFIX)/share/man
 
 
 OBJS= blocksort.o  \
@@ -34,8 +35,9 @@ OBJS= blocksort.o  \
       compress.o   \
       decompress.o \
       bzlib.o
+OBJS_PIC=$(patsubst %.o,%.pic.o,$(OBJS))
 
-all: libbz2.a bzip2 bzip2recover test
+all: libbz2.a bzip2 bzip2recover test bzip2-shared
 
 bzip2: libbz2.a bzip2.o
 	$(CC) $(CFLAGS) $(LDFLAGS) -o bzip2 bzip2.o -L. -lbz2
@@ -52,6 +54,19 @@ libbz2.a: $(OBJS)
 		$(RANLIB) libbz2.a ; \
 	fi
 
+bzip2-shared: $(OBJS_PIC)
+	$(CC) -shared -Wl,$(if $(shell ld -v 2>&1 | grep -i 'GNU ld'),-soname,-install_name) -Wl,libbz2.so.1.0 -o libbz2.so.1.0.6 $(OBJS_PIC) $(LDFLAGS)
+	$(CC) $(CFLAGS) -o bzip2-shared bzip2.c libbz2.so.1.0.6 $(LDFLAGS)
+
+libbz2_so_install: bzip2-shared
+	mkdir -p $(PREFIX)/lib
+	cp -f libbz2.so.1.0.6 $(PREFIX)/lib
+	ln -sf libbz2.so.1.0.6 $(PREFIX)/lib/libbz2.so.1.0
+	ln -sf libbz2.so.1.0.6 $(PREFIX)/lib/libbz2.so.1
+	ln -sf libbz2.so.1.0.6 $(PREFIX)/lib/libbz2.so
+	mkdir -p $(PREFIX)/bin
+	cp -f bzip2-shared $(PREFIX)/bin
+
 check: test
 test: bzip2
 	@cat words1
@@ -69,11 +82,11 @@ test: bzip2
 	cmp sample3.tst sample3.ref
 	@cat words3
 
-install: bzip2 bzip2recover
+install: bzip2 bzip2recover libbz2_so_install
 	if ( test ! -d $(PREFIX)/bin ) ; then mkdir -p $(PREFIX)/bin ; fi
 	if ( test ! -d $(PREFIX)/lib ) ; then mkdir -p $(PREFIX)/lib ; fi
-	if ( test ! -d $(PREFIX)/man ) ; then mkdir -p $(PREFIX)/man ; fi
-	if ( test ! -d $(PREFIX)/man/man1 ) ; then mkdir -p $(PREFIX)/man/man1 ; fi
+	if ( test ! -d $(mandir) ) ; then mkdir -p $(mandir) ; fi
+	if ( test ! -d $(mandir)/man1 ) ; then mkdir -p $(mandir)/man1 ; fi
 	if ( test ! -d $(PREFIX)/include ) ; then mkdir -p $(PREFIX)/include ; fi
 	cp -f bzip2 $(PREFIX)/bin/bzip2
 	cp -f bzip2 $(PREFIX)/bin/bunzip2
@@ -83,56 +96,41 @@ install: bzip2 bzip2recover
 	chmod a+x $(PREFIX)/bin/bunzip2
 	chmod a+x $(PREFIX)/bin/bzcat
 	chmod a+x $(PREFIX)/bin/bzip2recover
-	cp -f bzip2.1 $(PREFIX)/man/man1
-	chmod a+r $(PREFIX)/man/man1/bzip2.1
+	cp -f bzip2.1 $(mandir)/man1
+	chmod a+r $(mandir)/man1/bzip2.1
 	cp -f bzlib.h $(PREFIX)/include
 	chmod a+r $(PREFIX)/include/bzlib.h
 	cp -f libbz2.a $(PREFIX)/lib
 	chmod a+r $(PREFIX)/lib/libbz2.a
 	cp -f bzgrep $(PREFIX)/bin/bzgrep
-	ln -s -f $(PREFIX)/bin/bzgrep $(PREFIX)/bin/bzegrep
-	ln -s -f $(PREFIX)/bin/bzgrep $(PREFIX)/bin/bzfgrep
+	ln -s -f bzgrep $(PREFIX)/bin/bzegrep
+	ln -s -f bzgrep $(PREFIX)/bin/bzfgrep
 	chmod a+x $(PREFIX)/bin/bzgrep
 	cp -f bzmore $(PREFIX)/bin/bzmore
-	ln -s -f $(PREFIX)/bin/bzmore $(PREFIX)/bin/bzless
+	ln -s -f bzmore $(PREFIX)/bin/bzless
 	chmod a+x $(PREFIX)/bin/bzmore
 	cp -f bzdiff $(PREFIX)/bin/bzdiff
-	ln -s -f $(PREFIX)/bin/bzdiff $(PREFIX)/bin/bzcmp
+	ln -s -f bzdiff $(PREFIX)/bin/bzcmp
 	chmod a+x $(PREFIX)/bin/bzdiff
-	cp -f bzgrep.1 bzmore.1 bzdiff.1 $(PREFIX)/man/man1
-	chmod a+r $(PREFIX)/man/man1/bzgrep.1
-	chmod a+r $(PREFIX)/man/man1/bzmore.1
-	chmod a+r $(PREFIX)/man/man1/bzdiff.1
-	echo ".so man1/bzgrep.1" > $(PREFIX)/man/man1/bzegrep.1
-	echo ".so man1/bzgrep.1" > $(PREFIX)/man/man1/bzfgrep.1
-	echo ".so man1/bzmore.1" > $(PREFIX)/man/man1/bzless.1
-	echo ".so man1/bzdiff.1" > $(PREFIX)/man/man1/bzcmp.1
+	cp -f bzgrep.1 bzmore.1 bzdiff.1 $(mandir)/man1
+	chmod a+r $(mandir)/man1/bzgrep.1
+	chmod a+r $(mandir)/man1/bzmore.1
+	chmod a+r $(mandir)/man1/bzdiff.1
+	echo ".so man1/bzgrep.1" > $(mandir)/man1/bzegrep.1
+	echo ".so man1/bzgrep.1" > $(mandir)/man1/bzfgrep.1
+	echo ".so man1/bzmore.1" > $(mandir)/man1/bzless.1
+	echo ".so man1/bzdiff.1" > $(mandir)/man1/bzcmp.1
 
 clean: 
 	rm -f *.o libbz2.a bzip2 bzip2recover \
 	sample1.rb2 sample2.rb2 sample3.rb2 \
 	sample1.tst sample2.tst sample3.tst
 
-blocksort.o: blocksort.c
-	@cat words0
-	$(CC) $(CFLAGS) -c blocksort.c
-huffman.o: huffman.c
-	$(CC) $(CFLAGS) -c huffman.c
-crctable.o: crctable.c
-	$(CC) $(CFLAGS) -c crctable.c
-randtable.o: randtable.c
-	$(CC) $(CFLAGS) -c randtable.c
-compress.o: compress.c
-	$(CC) $(CFLAGS) -c compress.c
-decompress.o: decompress.c
-	$(CC) $(CFLAGS) -c decompress.c
-bzlib.o: bzlib.c
-	$(CC) $(CFLAGS) -c bzlib.c
-bzip2.o: bzip2.c
-	$(CC) $(CFLAGS) -c bzip2.c
-bzip2recover.o: bzip2recover.c
-	$(CC) $(CFLAGS) -c bzip2recover.c
+%.o: %.c
+	$(CC) $(CFLAGS) -o $@ -c $^
 
+%.pic.o: %.c
+	$(CC) $(CFLAGS) -fpic -fPIC -o $@ -c $^
 
 distclean: clean
 	rm -f manual.ps manual.html manual.pdf
EOF
}

configure() {
	true
}

MAKE_VARS="										\\
	PREFIX='$PKG_STAGING_DIR$INSTALL_PREFIX'	\\
"
