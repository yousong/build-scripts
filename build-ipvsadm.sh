#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=ipvsadm
PKG_VERSION=1.26
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.linuxvirtualserver.org/software/kernel-2.6/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=eac3ba3f62cd4dea2da353aeddd353a8
PKG_DEPENDS='libnl1 popt'
PKG_PLATFORM=linux

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
--- Makefile.orig	2016-01-15 16:47:34.815544002 +0800
+++ Makefile	2016-01-15 16:47:46.855548020 +0800
@@ -46,9 +46,9 @@ INSTALL		= install
 STATIC_LIBS	= libipvs/libipvs.a
 
 ifeq "${ARCH}" "sparc64"
-    CFLAGS = -Wall -Wunused -Wstrict-prototypes -g -m64 -pipe -mcpu=ultrasparc -mcmodel=medlow
+    CFLAGS += -Wall -Wunused -Wstrict-prototypes -g -m64 -pipe -mcpu=ultrasparc -mcmodel=medlow
 else
-    CFLAGS = -Wall -Wunused -Wstrict-prototypes -g
+    CFLAGS += -Wall -Wunused -Wstrict-prototypes -g
 endif
 
 
@@ -93,8 +93,9 @@
 
 all:            libs ipvsadm
 
+$(STATIC_LIBS): libs
 libs:
-		make -C libipvs
+		$(MAKE) -C libipvs
 
 ipvsadm:	$(OBJS) $(STATIC_LIBS)
 		$(CC) $(CFLAGS) -o $@ $^ $(LIBS)
@@ -116,7 +116,7 @@
 		rm -rf debian/tmp
 		find . -name '*.[ao]' -o -name "*~" -o -name "*.orig" \
 		  -o -name "*.rej" -o -name core | xargs rm -f
-		make -C libipvs clean
+		$(MAKE) -C libipvs clean
 
 distclean:	clean
 
--- libipvs/Makefile.orig	2016-01-15 16:47:54.727550125 +0800
+++ libipvs/Makefile	2016-01-15 16:47:59.775545894 +0800
@@ -1,7 +1,7 @@
 # Makefile for libipvs
 
 CC		= gcc
-CFLAGS		= -Wall -Wunused -Wstrict-prototypes -g -fPIC
+CFLAGS		+= -Wall -Wunused -Wstrict-prototypes -g -fPIC
 ifneq (0,$(HAVE_NL))
 CFLAGS		+= -DLIBIPVS_USE_NL
 endif
EOF
}

configure() {
	true
}

MAKE_ENVS+=(
	CFLAGS="${EXTRA_CFLAGS[*]} ${EXTRA_LDFLAGS[*]}"
)
MAKE_VARS+=(
	BUILD_ROOT="$PKG_STAGING_DIR/$INSTALL_PREFIX"
	MANDIR=share/man
	HAVE_NL=1
	POPT_LIB=-lpopt
)
