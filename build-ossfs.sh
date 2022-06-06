#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=ossfs
PKG_VERSION=1.80.6
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://github.com/aliyun/ossfs/archive/refs/tags/v$PKG_VERSION.tar.gz"
PKG_SOURCE_MD5SUM=b76bffbee3cbc0b96c89c314ffc2a933
PKG_DEPENDS='curl fuse libiconv libxml2 openssl'

PKG_SOURCE_UNTAR_FIXUP=1
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"
do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
--- src/Makefile.am.orig	2022-06-07 02:41:30.074471338 +0000
+++ src/Makefile.am	2022-06-07 02:41:32.868517557 +0000
@@ -36,9 +36,3 @@ if USE_SSL_NSS
 endif
 
 ossfs_LDADD = $(DEPS_LIBS)
-
-noinst_PROGRAMS = test_string_util
-
-test_string_util_SOURCES = string_util.cpp test_string_util.cpp test_util.h
-
-TESTS = test_string_util
EOF
}

CONFIGURE_ARGS+=(
	--with-openssl
)
