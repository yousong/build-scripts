#!/bin/bash -e
#
# Copyright 2021 (c) Yousong Zhou
#
PKG_NAME=dropwatch
PKG_VERSION=2021-05-27
PKG_SOURCE_PROTO=git
PKG_SOURCE_VERSION=ffaa31aac0887a9e0e3580a16e64d1cc652c3337
PKG_SOURCE_URL=https://github.com/nhorman/dropwatch.git
PKG_DEPENDS="libnl3 libpcap readline"

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# Upstream may not want to have patch anymore
	#
	# https://github.com/nhorman/dropwatch/commit/c18f3d25a94eb72145c663797794d2697a226594
	patch -p0 <<"EOF"
--- configure.ac.orig	2021-05-27 19:50:03.162948021 +0800
+++ configure.ac	2021-05-27 19:53:15.409200896 +0800
@@ -16,7 +16,12 @@ AC_CHECK_FUNCS(getopt_long)
 PKG_CHECK_MODULES([LIBNL3], [libnl-3.0], [], [AC_MSG_ERROR([libnl-3.0 is required])])
 PKG_CHECK_MODULES([LIBNLG3], [libnl-genl-3.0], [], [AC_MSG_ERROR([libnl-genl-3.0 is required])])
 # Fallback on using -lreadline as readline.pc is only available since version 8.0
-PKG_CHECK_MODULES([READLINE], [readline], [], [AC_MSG_ERROR([libreadline is required])])
+
+PKG_CHECK_MODULES([READLINE], [readline],
+		  [],
+		  [AC_CHECK_LIB([readline], [rl_initialize],
+				[],
+				[AC_MSG_ERROR([libreadline is required])])])
 PKG_CHECK_MODULES([LIBPCAP], [libpcap], [], [
         AC_CHECK_LIB(pcap, pcap_open_live,[],
                 [AC_MSG_ERROR([libpcap is required])])])
EOF
}

configure_pre() {
	cd "$PKG_BUILD_DIR"
	./autogen.sh
}

# dwdump.c: In function ‘dwdump_data_init’:
# dwdump.c:126:23: error: ‘SOL_NETLINK’ undeclared (first use in this function)
#   err = setsockopt(fd, SOL_NETLINK, NETLINK_NO_ENOBUFS, &optval,
#                        ^
# dwdump.c:126:23: note: each undeclared identifier is reported only once for each function it appears in
EXTRA_CFLAGS+=(-DSOL_NETLINK=270)

# To make a static build, add "-lncursesw -static" for the final link command
