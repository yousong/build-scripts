#!/bin/bash -e
#
# Copyright 2016-2020 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libtasn1
PKG_VERSION=4.16.0
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://ftp.gnu.org/gnu/libtasn1/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=531208de3729d42e2af0a32890f08736
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"

  corpus2array.c:123:4: error: 'for' loop initial declarations are only allowed in C99 mode

--- Makefile.am.orig	2020-08-07 17:19:30.743500447 +0800
+++ Makefile.am	2020-08-07 17:19:36.051491824 +0800
@@ -28,7 +28,7 @@ EXTRA_DIST = windows/asn1-parser/asn1-pa
 	CONTRIBUTING.md cfg.mk maint.mk AUTHORS NEWS ChangeLog		\
 	THANKS LICENSE
 
-SUBDIRS = lib src fuzz tests
+SUBDIRS = lib src tests
 
 if ENABLE_DOC
 SUBDIRS += doc examples
EOF
}
