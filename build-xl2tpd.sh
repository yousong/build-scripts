#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# libpcap is for compiling pfc
#
# xl2tpd-control requires fmemopen which is not available in darwin stdio.h
#
PKG_NAME=xl2tpd
PKG_VERSION=devel-20151125
PKG_SOURCE_VERSION=e2065bf0fc22ba33001ad503c01bba01648024a8
PKG_SOURCE="$PKG_NAME-$PKG_VERSION-$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/xelerance/xl2tpd/archive/$PKG_SOURCE_VERSION.tar.gz"
PKG_SOURCE_UNTAR_FIXUP=1
PKG_PLATFORM=linux
PKG_DEPENDS=ppp

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- Makefile.orig	2016-03-09 13:49:50.000000000 +0800
+++ Makefile	2016-03-09 13:49:55.000000000 +0800
@@ -113,7 +113,7 @@ BINDIR?=$(DESTDIR)${PREFIX}/bin
 MANDIR?=$(DESTDIR)${PREFIX}/share/man
 
 
-all: $(EXEC) pfc $(CONTROL_EXEC)
+all: $(EXEC) $(CONTROL_EXEC)
 
 clean:
 	rm -f $(OBJS) $(EXEC) pfc.o pfc $(CONTROL_EXEC)
--- network.c.orig	2016-03-09 13:45:40.000000000 +0800
+++ network.c	2016-03-09 13:46:08.000000000 +0800
@@ -99,12 +99,14 @@ int init_network (void)
 
 #endif
 
+#ifdef SO_NO_CHECK
     /* turn off UDP checksums */
     arg=1;
     if (setsockopt(server_socket, SOL_SOCKET, SO_NO_CHECK , (void*)&arg,
                    sizeof(arg)) ==-1) {
       l2tp_log(LOG_INFO, "unable to turn off UDP checksums");
     }
+#endif
 
 #ifdef USE_KERNEL
     if (gconfig.forceuserspace)
--- md5.c.orig	2016-03-09 13:48:14.000000000 +0800
+++ md5.c	2016-03-09 13:48:20.000000000 +0800
@@ -166,7 +166,7 @@ void MD5Final (unsigned char digest[16],
     MD5Transform (ctx->buf, (uint32 *) ctx->in);
     byteReverse ((unsigned char *) ctx->buf, 4);
     memcpy (digest, ctx->buf, 16);
-    memset (ctx, 0, sizeof (ctx));      /* In case it's sensitive */
+    memset (ctx, 0, sizeof (*ctx));      /* In case it's sensitive */
 }
 
 #ifndef ASM_MD5
EOF
}

configure() {
	true
}

# NOTE: /usr/sbin/pppd is expected by default
#
#	PATH_USR_SBIN=$INSTALL_PREFIX/sbin/pppd
#	PATH_USR_SBIN=/usr/sbin/pppd
#
EXTRA_CFLAGS="$EXTRA_CFLAGS		\\
	-DPPPD='\\\\\\\"$INSTALL_PREFIX/sbin/pppd\\\\\\\"'	\\
"
MAKE_VARS="$MAKE_VARS			\\
	PREFIX='$INSTALL_PREFIX'	\\
"
