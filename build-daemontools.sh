#!/bin/bash -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=daemontools
PKG_VERSION=0.76
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://cr.yp.to/daemontools/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=1871af2453d6e464034968a0fbcb2bfc
PKG_SOURCE_UNTAR_FIXUP=1
PKG_DEPENDS=''

. "$PWD/env.sh"

prepare_extra() {
	local d0="$PKG_SOURCE_DIR"
	local d1="$(echo "$PKG_SOURCE_DIR"/*)"

	# the original layout is admin/daemontools-x.x
	mv "$d1"/* "$d0"
	rmdir "$d1"
}

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
Fixes the following linking error

	/usr/bin/ld: errno: TLS definition in /lib/libc.so.6 section .tbss mismatches non-TLS reference in envdir.o

--- src/error.h.orig	2017-09-12 15:37:37.058203228 +0800
+++ src/error.h	2017-09-12 15:37:40.762204387 +0800
@@ -3,6 +3,8 @@
 #ifndef ERROR_H
 #define ERROR_H
 
+#include <errno.h>
+
 extern int errno;
 
 extern int error_intr;
EOF

	patch -p0 <<EOF
Find service settings in \$INSTALL_PREFIX/.usr/etc/service instead of /service

--- src/svscanboot.sh.orig	2017-09-12 15:48:14.246402660 +0800
+++ src/svscanboot.sh	2017-09-12 15:50:54.218452729 +0800
@@ -1,11 +1,11 @@
 
-PATH=/command:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin
+PATH="$INSTALL_PREFIX/bin:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin"
 
 exec </dev/null
 exec >/dev/null
 exec 2>/dev/null
 
-/command/svc -dx /service/* /service/*/log
+"$INSTALL_PREFIX/bin/svc" -dx "$INSTALL_PREFIX/etc/service"/* "$INSTALL_PREFIX/etc/service"/*/log
 
-env - PATH=\$PATH svscan /service 2>&1 | \\
+env - PATH=\$PATH svscan "$INSTALL_PREFIX/etc/service" 2>&1 | \\
 env - PATH=\$PATH readproctitle service errors: ................................................................................................................................................................................................................................................................................................................................................................................................................
EOF
}

configure() {
	true
}

compile() {
	cd "$PKG_BUILD_DIR"
	# this will also run tests in src/rts.tests
	package/compile
}

staging() {
	local bindir="$PKG_STAGING_DIR$INSTALL_PREFIX/bin"

	mkdir -p "$bindir"
	cpdir "$PKG_BUILD_DIR/command" "$bindir"
}
