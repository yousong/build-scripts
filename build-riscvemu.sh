#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=riscvemu
PKG_VERSION=2017-01-07
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="http://bellard.org/riscvemu/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1144f6627e1b7264796acbdf3dc1d91e
PKG_DEPENDS='curl'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
--- Makefile.orig	2017-01-10 11:40:43.589357310 +0800
+++ Makefile	2017-01-10 11:41:31.517372310 +0800
@@ -30,6 +30,9 @@ RISCVEMU_OBJS+=fs_net.o
 RISCVEMU_LIBS+=-lcurl
 endif
 
+CFLAGS+=$(EXTRA_CFLAGS)
+LDFLAGS+=$(EXTRA_LDFLAGS)
+
 riscvemu32: riscvemu32.o $(RISCVEMU_OBJS)
 	$(CC) $(LDFLAGS) -o $@ $^ $(RISCVEMU_LIBS)
 
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

MAKE_VARS="$MAKE_VARS				\\
	EXTRA_CFLAGS='$EXTRA_CFLAGS'	\\
	EXTRA_LDFLAGS='$EXTRA_LDFLAGS'	\\
"
