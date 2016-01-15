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
	cd "$PKG_BUILD_DIR"

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
EOF
}

configure_pre() {
	cd "$PKG_BUILD_DIR"
	autoconf_fixup
}

# --with-perl-modules accepts arguments to Makefile.PL script.  Trace PERLARGS
# for details.  The Makefile for perl modules was not generated at configure
# time, but at build time with Makefile
#
# - http://modperlbook.org/html/3-9-1-Installing-Perl-Modules-into-a-Nonstandard-Directory.html
CONFIGURE_ARGS="									\\
	--with-defaults									\\
	--with-openssl=yes								\\
	--with-perl-modules='PREFIX=$INSTALL_PREFIX'	\\
"
