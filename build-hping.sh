#!/bin/bash -e
#
# Copyright 2018 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=hping
PKG_VERSION=2014-12-26
PKG_SOURCE_PROTO=git
PKG_SOURCE_URL="https://github.com/antirez/hping.git"
PKG_SOURCE_VERSION=3547c7691742c6eaa31f8402e0ccbb81387c1b99

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	patch -p0 <<"EOF"
--- libpcap_stuff.c.orig	2019-01-04 12:47:29.818878495 +0000
+++ libpcap_stuff.c	2019-01-04 12:47:33.078873333 +0000
@@ -16,7 +16,7 @@
 #include <string.h>
 #include <stdlib.h>
 #include <sys/ioctl.h>
-#include <net/bpf.h>
+#include <pcap/bpf.h>
 #include <pcap.h>
 
 #include "globals.h"
EOF
}

# requires tcl-devel
CONFIGURE_ARGS+=(
	--no-tcl
)

MAKE_VARS+=(
	CCOPT="${EXTRA_CFLAGS[*]} ${EXTRA_LDFLAGS[*]}"
)

staging() {
	local d="$PKG_STAGING_DIR$INSTALL_PREFIX"
	local sbindir="$d/sbin"
	local mandir="$d/share/man"

	cd "$PKG_BUILD_DIR"
	mkdir -p "$sbindir"
	command install -m 755 hping3 "$sbindir"
	ln -s hping3 "$sbindir/hping"
	ln -s hping3 "$sbindir/hping2"

	mkdir -p "$mandir/man8"
	command install -m 644 ./docs/hping3.8 "$mandir/man8"
}
