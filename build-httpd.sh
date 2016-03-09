#!/bin/sh -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Requires Apache Portable Runtime @apr
# Requires Apache Portable Runtime utility @apr-util
# @nghttp2 for HTTP/2 support
# @openssl for HTTPS support
#
# HTTP/2 support was available starting with Apache 2.4.12, then at 2.4.17
# mod_http2 was introduced
#
# - Official Patches for publically released versions of Apache, http://www.us.apache.org/dist//httpd/patches/
#
PKG_NAME=httpd
PKG_VERSION=2.4.18
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_SOURCE_URL="http://www.us.apache.org/dist//httpd/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=3690b3cc991b7dfd22aea9e1264a11b9
PKG_DEPENDS='apr apr-util libiconv nghttp2 openssl pcre'

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# use a libexec/apache2/ for apache modules
	patch -p0 <<"EOF"
--- config.layout.orig	2016-01-06 13:59:58.729021336 +0800
+++ config.layout	2016-01-06 14:00:04.793019093 +0800
@@ -41,7 +41,7 @@
     bindir:        ${exec_prefix}/bin
     sbindir:       ${exec_prefix}/sbin
     libdir:        ${exec_prefix}/lib
-    libexecdir:    ${exec_prefix}/libexec
+    libexecdir:    ${exec_prefix}/libexec+
     mandir:        ${prefix}/man
     sysconfdir:    ${prefix}/etc+
     datadir:       ${prefix}/share+
EOF
}

CONFIGURE_ARGS="$CONFIGURE_ARGS		\\
	--enable-layout=GNU				\\
"
