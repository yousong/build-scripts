#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=tcpreplay
PKG_VERSION=4.1.1
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://github.com/appneta/tcpreplay/releases/download/v$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=80394c33fe697b53b69eac9bb0968ae9
PKG_DEPENDS=libpcap
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- configure.ac.orig	2016-08-11 12:32:15.534566107 +0800
+++ configure.ac	2016-08-11 12:32:21.430567852 +0800
@@ -807,7 +807,7 @@ if test -n "$LPCAPINCDIR"; then
     CFLAGS="$CFLAGS -I$LPCAPINCDIR"
 else
     OLDCFLAGS="$CFLAGS"
-    LPCAPINCDIR=$(echo $CFLAGS | sed -e 's/^\-I//')
+    LPCAPINCDIR=$(pcap-config --cflags | sed -e 's/^\-I//')
     LPCAPINC="$LPCAPINCDIR/pcap.h"
 fi
 
EOF
}

CONFIGURE_ARGS="$CONFIGURE_ARGS	\\
	--enable-pcapconfig			\\
"
