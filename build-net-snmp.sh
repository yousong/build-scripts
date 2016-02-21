#!/bin/sh -e
#
PKG_NAME=net-snmp
PKG_VERSION=5.7.3
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://sourceforge.net/projects/net-snmp/files/net-snmp/$PKG_VERSION/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d4a3459e1577d0efa8d96ca70a885e53
PKG_DEPENDS=openssl

. "$PWD/env.sh"

if os_is_linux; then
	PKG_DEPENDS="$PKG_DEPENDS libnl3"
fi

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# It's a mess in configure.d
	patch -p0 <<"EOF"
--- apps/Makefile.in.orig	2016-01-15 23:08:21.438696906 +0800
+++ apps/Makefile.in	2016-01-15 23:11:02.314743436 +0800
@@ -85,7 +85,7 @@
 MYSQL_INCLUDES	= @MYSQL_INCLUDES@
 
 VAL_LIBS	= @VAL_LIBS@
-LIBS		= $(USELIBS) $(VAL_LIBS) @LIBS@
+LIBS		= $(USELIBS) $(VAL_LIBS) @LIBS@ -lcrypto
 PERLLDOPTS_FOR_APPS = @PERLLDOPTS_FOR_APPS@
 PERLLDOPTS_FOR_LIBS = @PERLLDOPTS_FOR_LIBS@
 
--- configure.ac.orig	2016-01-15 23:08:21.438696906 +0800
+++ configure.ac	2016-01-15 23:11:02.314743436 +0800
@@ -79,6 +79,7 @@ if test "x$with_nl" != "xno"; then
 AC_SUBST(PARTIALTARGETFLAGS)
 AC_SUBST(ac_cv_NETSNMP_SYSTEM_INCLUDE_FILE)
 
+AC_CONFIG_FILES([include/net-snmp/system/darwin.h])
 AC_CONFIG_FILES([Makefile:Makefile.top:Makefile.in:Makefile.rules])
 AC_CONFIG_FILES([snmplib/Makefile:Makefile.top:snmplib/Makefile.in:Makefile.rules:snmplib/Makefile.depend])
 AC_CONFIG_FILES([apps/Makefile:Makefile.top:apps/Makefile.in:Makefile.rules:apps/Makefile.depend])
--- configure.d/config_os_libs2.orig	2016-01-15 23:08:21.438696906 +0800
+++ configure.d/config_os_libs2	2016-01-15 23:11:02.314743436 +0800
@@ -226,10 +226,10 @@ if test "x$with_nl" != "xno"; then
     case $target_os in
     linux*) # Check for libnl (linux)
         netsnmp_save_CPPFLAGS="$CPPFLAGS"
-        CPPFLAGS="-I/usr/include/libnl3 $CPPFLAGS"
+        CPPFLAGS="`pkg-config --cflags libnl-3.0` $CPPFLAGS"
         NETSNMP_SEARCH_LIBS(nl_connect, nl-3,
             [AC_CHECK_HEADERS(netlink/netlink.h)
-            EXTERNAL_MIBGROUP_INCLUDES="$EXTERNAL_MIBGROUP_INCLUDES -I/usr/include/libnl3"],
+            EXTERNAL_MIBGROUP_INCLUDES="$EXTERNAL_MIBGROUP_INCLUDES `pkg-config --cflags libnl-3.0`"],
             [CPPFLAGS="$netsnmp_save_CPPFLAGS"], [], [], [LMIBLIBS])
         if test "x$ac_cv_header_netlink_netlink_h" != xyes; then
             NETSNMP_SEARCH_LIBS(nl_connect, nl, [
--- configure.d/config_os_progs.orig	2016-01-16 11:04:26.000000000 +0800
+++ configure.d/config_os_progs	2016-01-16 11:14:37.000000000 +0800
@@ -273,6 +273,12 @@ done
 changequote([, ])
 AC_MSG_RESULT($ac_cv_NETSNMP_SYSTEM_INCLUDE_FILE)
 AC_DEFINE_UNQUOTED(NETSNMP_SYSTEM_INCLUDE_FILE, "$ac_cv_NETSNMP_SYSTEM_INCLUDE_FILE")
+if test "x$filebase" = "xdarwin"; then
+    MACOSX_PRODUCT_VERSION="$target_os"
+    MACOSX_PRODUCT_VERSION_MAJOR="`echo $target_os | $SED 's/darwin\([[0-9]]\+\).*/\1/'`"
+    AC_SUBST(MACOSX_PRODUCT_VERSION)
+    AC_SUBST(MACOSX_PRODUCT_VERSION_MAJOR)
+fi
 
 
 #       Determine appropriate <net-snmp/machine/{cpu}.h> include
--- /dev/null	2016-01-16 11:16:23.000000000 +0800
+++ include/net-snmp/system/darwin.h.in	2016-01-16 11:02:37.000000000 +0800
@@ -0,0 +1,8 @@
+#include "darwin13.h"
+/*
+ * This section defines Mac OS X @MACOSX_PRODUCT_VERSION@ (and later) specific additions.
+ */
+#undef darwin
+#undef darwin@MACOSX_PRODUCT_VERSION_MAJOR@
+#define darwin@MACOSX_PRODUCT_VERSION_MAJOR@ darwin
+#define darwin @MACOSX_PRODUCT_VERSION_MAJOR@
EOF
}

configure_pre() {
	cd "$PKG_SOURCE_DIR"
	autoconf_fixup
}

# --with-perl-modules accepts arguments to Makefile.PL script.  Trace PERLARGS
# for details.  The Makefile for perl modules was not generated at configure
# time, but at build time with Makefile
#
# - http://modperlbook.org/html/3-9-1-Installing-Perl-Modules-into-a-Nonstandard-Directory.html
CONFIGURE_ARGS="$CONFIGURE_ARGS						\\
	--with-defaults									\\
	--with-openssl=yes								\\
	--with-perl-modules='PREFIX=$INSTALL_PREFIX'	\\
"
