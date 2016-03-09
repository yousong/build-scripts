#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=lmbench
PKG_VERSION=3
PKG_SOURCE="$PKG_NAME$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.bitmover.com/lmbench/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=79f1861dfdd0110c6dd9d24d1d5473e7
PKG_BUILD_DIR_BASENAME="lmbench$PKG_VERSION"

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- src/Makefile.orig	2016-03-09 15:58:34.602902952 +0800
+++ src/Makefile	2016-03-09 16:00:00.854927671 +0800
@@ -228,7 +228,7 @@ testmake: $(SRCS) $(UTILS) # used by scr
 	install install-target dist get edit get-e clean clobber \
 	share depend testmake
 
-$O/lmbench : ../scripts/lmbench bk.ver
+$O/lmbench : ../scripts/lmbench
 	rm -f $O/lmbench
 	sed -e "s/<version>/`cat bk.ver`/g" < ../scripts/lmbench > $O/lmbench
 	chmod +x $O/lmbench
--- src/lib_debug.c.orig	2016-03-09 15:18:42.834149422 +0800
+++ src/lib_debug.c	2016-03-09 15:18:54.846157153 +0800
@@ -1,5 +1,6 @@
 #include "bench.h"
 #include "lib_debug.h"
+#include <math.h>
 
 /*
  * return micro-seconds / iteration at the the fraction point.
EOF
}

configure() {
	true
}

staging() {
	true
}

install() {
	true
}

install_post() {
	cat >&2 <<EOF
Run tests with

	cd $PKG_SOURCE_DIR
	make results
EOF
}
