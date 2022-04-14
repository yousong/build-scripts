#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Enable tcp_wrappers also requires libnsl
#
PKG_NAME=vsftpd
PKG_VERSION=3.0.5
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://security.appspot.com/downloads/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=efbf362a65bec771bc15ad311f5a982e
PKG_DEPENDS="libcap libnsl openssl tcp_wrappers"

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
Allow build system to specify flags

--- Makefile.orig	2022-04-14 03:04:11.308773821 +0000
+++ Makefile	2022-04-14 03:04:42.832279185 +0000
@@ -1,7 +1,7 @@
 # Makefile for systems with GNU tools
 CC 	=	gcc
 INSTALL	=	install
-IFLAGS  = -idirafter dummyinc
+IFLAGS  = -idirafter dummyinc $(CPPFLAGS)
 #CFLAGS = -g
 CFLAGS	=	-O2 -fPIE -fstack-protector --param=ssp-buffer-size=4 \
 	-Wall -W -Wshadow -Werror -Wformat-security \
@@ -10,7 +10,7 @@ CFLAGS	=	-O2 -fPIE -fstack-protector --p
 
 LIBS	=	`./vsf_findlibs.sh`
 LINK	=	-Wl,-s
-LDFLAGS	=	-fPIE -pie -Wl,-z,relro -Wl,-z,now
+LDFLAGS+=	-fPIE -pie -Wl,-z,relro -Wl,-z,now
 
 OBJS	=	main.o utility.o prelogin.o ftpcmdio.o postlogin.o privsock.o \
 		tunables.o ftpdataio.o secbuf.o ls.o \
EOF
}

configure() {
	cat >"$PKG_BUILD_DIR/builddefs.h" <<-"EOF"
		#ifndef VSF_BUILDDEFS_H
		#define VSF_BUILDDEFS_H

		#define VSF_BUILD_TCPWRAPPERS
		#define VSF_BUILD_PAM
		#define VSF_BUILD_SSL

		#endif /* VSF_BUILDDEFS_H */
	EOF
}
