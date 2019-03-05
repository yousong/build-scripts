#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Uhh, CentOS does not provide .rpm for this
#
# Requires
#
# 	sudo yum install -y fcgi-devel
#
PKG_NAME=fcgiwrap
PKG_VERSION=1.1.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/gnosek/fcgiwrap/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=d14f56bda6758a6e02aa7b3fb125cbce
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- Makefile.in.orig	2019-03-05 09:36:04.989993870 +0000
+++ Makefile.in	2019-03-05 09:36:55.977857409 +0000
@@ -1,6 +1,8 @@
-targetdir = $(DESTDIR)@prefix@@sbindir@
-man8dir = $(DESTDIR)@prefix@@mandir@/man8
-datarootdir =
+prefix = @prefix@
+exec_prefix = @exec_prefix@
+datarootdir = @datarootdir@
+targetdir = $(DESTDIR)@sbindir@
+man8dir = $(DESTDIR)@mandir@/man8
 
 .PHONY:	clean distclean
 
EOF
}
