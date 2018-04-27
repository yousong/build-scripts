#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Basic use
#
#	beanstalkd -h					# help
#	beanstalkd -VVVV				# verbose
#	# use binlog and fsync on every update
#	beanstalkd -VVVV -b $PWD -f0
#
# Files
#
#	linux.c		epoll wrapup
#	prot.c
#		prothandle()	sock event cb
#
#
PKG_NAME=beanstalkd
PKG_VERSION=1.10
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/kr/beanstalkd/archive/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=0994d83b03bde8264a555ea63eed7524
PKG_SOURCE_UNTAR_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p1 <<"EOF"

  - mkdir before installing any thing to it
  - clock_gettime requires -lrt for earlier versions of glibc

--- a/Makefile.orig	2017-11-24 15:58:25.507532051 +0800
+++ b/Makefile	2017-11-24 15:58:29.171533235 +0800
@@ -55,6 +55,7 @@ install: $(BINDIR) $(BINDIR)/$(TARG)
 $(BINDIR):
 	$(INSTALL) -d $@
 
+$(BINDIR)/%: $(BINDIR)
 $(BINDIR)/%: %
 	$(INSTALL) $< $@
 
--- a/Makefile.orig	2017-11-24 15:58:25.507532051 +0800
+++ b/Makefile	2017-11-24 15:58:29.171533235 +0800
@@ -54,6 +54,7 @@ install: $(BINDIR) $(BINDIR)/$(TARG)
 bench: ct/_ctcheck
 	ct/_ctcheck -b
 
+ct/_ctcheck: export LDFLAGS+=-lrt
 ct/_ctcheck: ct/_ctcheck.o ct/ct.o $(OFILES) $(TOFILES)
 
 ct/_ctcheck.c: $(TOFILES) ct/gen
EOF

	patch -p1 <<"EOF"

 Fix compilation error with "make ct/_ctcheck"

--- a/ct/ct.c.orig	2017-11-24 16:24:44.579998084 +0800
+++ b/ct/ct.c	2017-11-24 16:25:49.840013536 +0800
@@ -14,6 +14,7 @@
 #include <errno.h>
 #include <sys/time.h>
 #include <stdint.h>
+#include <inttypes.h>
 #include "internal.h"
 #include "ct.h"
 
@@ -24,7 +25,7 @@ static int64 bstart, bdur;
 static int btiming; // bool
 static int64 bbytes;
 static const int64 Second = 1000 * 1000 * 1000;
-static const int64 BenchTime = Second;
+static const int64 BenchTime = 1000 * 1000 * 1000;
 static const int MaxN = 1000 * 1000 * 1000;
 
 
@@ -40,6 +41,7 @@ nstime()
 
 #else
 
+#include <time.h>
 static int64
 nstime()
 {
@@ -416,7 +418,7 @@ runbench(Benchmark *b)
         runbenchn(b, n);
     }
     if (b->status == 0) {
-        printf("%8d\t%10lld ns/op", n, b->dur/n);
+        printf("%8d\t%10" PRId64 " ns/op", n, b->dur/n);
         if (b->bytes > 0) {
             double mbs = 0;
             if (b->dur > 0) {
EOF
}

configure() {
	true
}

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
)

beanstalk_test_and_bench() {
	cd "$PKG_BUILD_DIR"
	"${MAKEJ[@]}" ct/_ctcheck
	"${MAKEJ[@]}" bench
}
