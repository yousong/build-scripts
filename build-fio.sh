#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=fio
PKG_VERSION=2.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://brick.kernel.dk/snaps/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=edfd730054b402235f7cf0f61d5ce883
PKG_DEPENDS=zlib

. "$PWD/env.sh"

if os_is_linux; then
	PKG_DEPENDS+=( libaio)
fi

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
Fixes compiling error

	In file included from oslib/libmtd_legacy.c:38:0:
	oslib/libmtd.h:288:8: error: unknown type name ‘uint8_t’
	oslib/libmtd.h:305:4: error: unknown type name ‘uint64_t’
	oslib/libmtd.h:305:20: error: unknown type name ‘uint64_t’
	oslib/libmtd.h:322:5: error: unknown type name ‘uint64_t’
	oslib/libmtd.h:322:21: error: unknown type name ‘uint64_t’
	make[2]: *** [oslib/libmtd_legacy.o] Error 1

--- oslib/libmtd.h.orig	2017-06-07 22:34:54.164956014 +0800
+++ oslib/libmtd.h	2017-06-07 22:35:04.848959358 +0800
@@ -29,6 +29,8 @@
 extern "C" {
 #endif
 
+#include <stdint.h>
+
 /* Maximum MTD device name length */
 #define MTD_NAME_MAX 127
 /* Maximum MTD device type string length */
EOF
}

CONFIGURE_ARGS+=(
	--extra-cflags="${EXTRA_CFLAGS[*]} ${EXTRA_LDFLAGS[*]}"
)

MAKE_VARS+=(
	V=s
	mandir="$INSTALL_PREFIX/share/man"
	sharedir="$INSTALL_PREFIX/share/fio"
)
