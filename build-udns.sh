#!/bin/sh -e

PKG_NAME=udns
PKG_VERSION=0.4
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.corpit.ru/mjt/udns/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=51e141b044b078d71ebb71f823959c1b
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- /dev/null	2016-01-04 02:31:18.900000000 +0800
+++ configure.ac	2016-02-22 20:00:45.598775056 +0800
@@ -0,0 +1,29 @@
+# Copyright 2016 Yousong Zhou
+
+AC_PREREQ([2.67])
+AC_INIT([libudns], [0.4])
+AC_CONFIG_HEADERS([config.h])
+
+AM_INIT_AUTOMAKE([foreign])
+LT_INIT
+
+dnl Checks for programs.
+AC_PROG_CC
+AC_PROG_INSTALL
+AC_PROG_LN_S
+AC_PROG_LIBTOOL
+
+dnl Checks for library functions.
+AC_CHECK_LIB(socket, connect)
+AC_CHECK_FUNCS([malloc memset socket])
+AC_CHECK_FUNCS([getopt poll])
+AC_CHECK_FUNCS([inet_pton inet_ntop],
+			   [AC_DEFINE([HAVE_INET_PTON_NTOP], [1], [Have inet_pton and inet_ntop])])
+AC_CHECK_TYPE([struct sockaddr_in6],
+			  [AC_DEFINE([HAVE_IPv6], [1], [Have ipv6 support])],
+			  [],
+			  [#include <sys/socket.h>
+			   #include <netinet/in.h>])
+
+AC_CONFIG_FILES([Makefile])
+AC_OUTPUT
--- /dev/null	2016-01-04 02:31:18.900000000 +0800
+++ Makefile.am	2016-02-22 20:12:01.938987311 +0800
@@ -0,0 +1,16 @@
+# Copyright 2016 Yousong Zhou
+
+lib_LTLIBRARIES=libudns.la
+libudns_la_SOURCES= udns_dn.c udns_dntosp.c udns_parse.c udns_resolver.c udns_init.c \
+	udns_misc.c udns_XtoX.c \
+	udns_rr_a.c udns_rr_ptr.c udns_rr_mx.c udns_rr_txt.c udns_bl.c \
+	udns_rr_srv.c udns_rr_naptr.c udns_codes.c udns_jran.c
+include_HEADERS= udns.h
+
+bin_PROGRAMS = dnsget rblcheck ex-rdns
+dnsget_SOURCES = dnsget.c
+rblcheck_SOURCES = rblcheck.c
+ex_rdns_SOURCES = ex-rdns.c
+dnsget_LDADD = $(top_builddir)/libudns.la
+rblcheck_LDADD = $(top_builddir)/libudns.la
+ex_rdns_LDADD = $(top_builddir)/libudns.la
EOF
}
