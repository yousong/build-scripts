#!/bin/bash -e
#
# Copyright 2022 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=tcp_wrappers
PKG_VERSION=7.6
PKG_SOURCE="${PKG_NAME}_$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://ftp.porcupine.org/pub/security/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=e6fa25f71226d090f34de3f6b122fb5a

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- Makefile.orig	2022-04-14 04:37:08.659085614 +0000
+++ Makefile	2022-04-14 04:38:09.992070484 +0000
@@ -659,7 +659,7 @@ HOSTNAME= -DALWAYS_HOSTNAME
 SHELL	= /bin/sh
 .c.o:;	$(CC) $(CFLAGS) -c $*.c
 
-CFLAGS	= -O -DFACILITY=$(FACILITY) $(ACCESS) $(PARANOID) $(NETGROUP) \
+CFLAGS	+= -O -DFACILITY=$(FACILITY) $(ACCESS) $(PARANOID) $(NETGROUP) \
 	$(BUGS) $(SYSTYPE) $(AUTH) $(UMASK) \
 	-DREAL_DAEMON_DIR=\"$(REAL_DAEMON_DIR)\" $(STYLE) $(KILL_OPT) \
 	-DSEVERITY=$(SEVERITY) -DRFC931_TIMEOUT=$(RFC931_TIMEOUT) \
--- percent_m.c.orig	2022-04-14 04:43:24.823082321 +0000
+++ percent_m.c	2022-04-14 04:42:23.630095739 +0000
@@ -13,7 +13,7 @@ static char sccsid[] = "@(#) percent_m.c
 #include <string.h>
 
 extern int errno;
-#ifndef SYS_ERRLIST_DEFINED
+#ifndef SYS_ERRLIST_DEFINED && !defined(HAVE_STRERROR)
 extern char *sys_errlist[];
 extern int sys_nerr;
 #endif
@@ -29,11 +29,15 @@ char   *ibuf;
 
     while (*bp = *cp)
 	if (*cp == '%' && cp[1] == 'm') {
+#ifdef HAVE_STRERROR
+	    strcpy(bp, strerror(errno));
+#else
 	    if (errno < sys_nerr && errno > 0) {
 		strcpy(bp, sys_errlist[errno]);
 	    } else {
 		sprintf(bp, "Unknown error %d", errno);
 	    }
+#endif
 	    bp += strlen(bp);
 	    cp += 2;
 	} else {
EOF
}

configure() {
	true
}

MAKE_VARS+=(
	REAL_DAEMON_DIR="$INSTALL_PREFIX/bin"
)

EXTRA_CFLAGS+=(
	-DSYS_ERRLIST_DEFINED
	-DHAVE_STRERROR
	-fPIE
)

compile() {
	cd "$PKG_BUILD_DIR"
	if os_is_linux; then
		build_compile_make linux
	elif os_is_darwin; then
		build_compile_make generic
	else
		false
	fi
}

staging() {
	local d="$PKG_STAGING_DIR$INSTALL_PREFIX"
	local incdir="$d/include"
	local bindir="$d/bin"
	local libdir="$d/lib"
	local mandir="$d/share/man"
	local manfile

	mkdir -p "$incdir"
	mkdir -p "$bindir"
	mkdir -p "$libdir"
	cp "$PKG_BUILD_DIR/tcpd.h" "$incdir"
	cp "$PKG_BUILD_DIR/libwrap.a" "$libdir"

	find "$PKG_BUILD_DIR" -type f -name "*.[1-9]" \
		| while read manfile; do
		mkdir -p "$mandir/man${manfile##*.}"
		cp "$manfile" "$mandir/man${manfile##*.}"
		if test -x "${manfile%.*}"; then
			cp "${manfile%.*}" "$bindir"
		fi
	done
}
