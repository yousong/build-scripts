#!/bin/bash -e
#
# Copyright 2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=libpcap
PKG_VERSION=1.7.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.tcpdump.org/release/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=b2e13142bbaba857ab1c6894aedaf547

. "$PWD/env.sh"
if os_is_linux; then
	PKG_DEPENDS=libnl3
fi

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- configure.in.orig	2016-02-25 15:11:22.702467210 +0800
+++ configure.in	2016-02-25 15:19:26.502618633 +0800
@@ -466,19 +466,15 @@ linux)
 		#
 		# Try libnl 3.x first.
 		#
-		AC_CHECK_LIB(nl-3, nl_socket_alloc,
-		[
-			#
-			# Yes, we have libnl 3.x.
-			#
-			LIBS="${libnldir} -lnl-genl-3 -lnl-3 $LIBS"
-			AC_DEFINE(HAVE_LIBNL,1,[if libnl exists])
-			AC_DEFINE(HAVE_LIBNL_3_x,1,[if libnl exists and is version 3.x])
-			AC_DEFINE(HAVE_LIBNL_NLE,1,[libnl has NLE_FAILURE])
-			AC_DEFINE(HAVE_LIBNL_SOCKETS,1,[libnl has new-style socket api])
-			V_INCLS="$V_INCLS ${incdir}"
-			have_any_nl="yes"
-		],[], ${incdir} ${libnldir} -lnl-genl-3 -lnl-3 )
+		PKG_CHECK_MODULES([NL3], [libnl-3.0 libnl-genl-3.0],
+						  [AC_DEFINE(HAVE_LIBNL,1,[if libnl exists])
+						   AC_DEFINE(HAVE_LIBNL_3_x,1,[if libnl exists and is version 3.x])
+						   AC_DEFINE(HAVE_LIBNL_NLE,1,[libnl has NLE_FAILURE])
+						   AC_DEFINE(HAVE_LIBNL_SOCKETS,1,[libnl has new-style socket api])
+						   V_INCLS="${NL3_CFLAGS} $V_INCLS"
+						   LIBS="$NL3_LIBS $LIBS"
+						   have_any_nl="yes"
+						   ])
 
 		if test x$have_any_nl = xno ; then
 			#
--- Makefile.in.orig	2016-02-25 15:54:18.195273308 +0800
+++ Makefile.in	2016-02-25 15:54:29.915276977 +0800
@@ -62,7 +62,7 @@ DEPENDENCY_CFLAG = @DEPENDENCY_CFLAG@
 PROG=libpcap
 
 # Standard CFLAGS
-FULL_CFLAGS = $(CCOPT) $(INCLS) $(DEFS) $(CFLAGS)
+FULL_CFLAGS = $(INCLS) $(CCOPT) $(DEFS) $(CFLAGS)
 
 INSTALL = @INSTALL@
 INSTALL_PROGRAM = @INSTALL_PROGRAM@
EOF
}

configure_pre() {
	cd "$PKG_SOURCE_DIR"
	# the ACL_LBL_XXX there may not be available on current host
	if [ ! -f "aclocal.m4.orig" ]; then
		cp aclocal.m4 aclocal.m4.orig
	else
		cp aclocal.m4.orig aclocal.m4
	fi
	aclocal --output=- >>aclocal.m4
	autoconf_fixup
}

# we do not want to depend on system's libdbus without setting RPATH.  This is
# important for other packages like bmv2 depending on us yet failed to run
# conftest because of dynamic linking issues
CONFIGURE_ARGS+=(
	--disable-dbus
)
