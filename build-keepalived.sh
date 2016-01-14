#!/bin/sh -e
#
PKG_NAME=keepalived
PKG_VERSION=1.2.19
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://www.keepalived.org/software/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=5c98b06639dd50a6bff76901b53febb6
PKG_DEPENDS='libnl net-snmp openssl'
PKG_PLATFORM=linux

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_BUILD_DIR"

	patch -p0 <<"EOF"
--- Makefile.in.orig	2016-01-14 17:58:09.101827556 +0800
+++ Makefile.in	2016-01-14 17:58:42.385837973 +0800
@@ -63,9 +63,9 @@ install:
 	$(MAKE) -C keepalived install
 	$(MAKE) -C genhash install
 ifeq (@SNMP_SUPPORT@, _WITH_SNMP_)
-	mkdir -p $(DESTDIR)/usr/share/snmp/mibs/
-	cp -f doc/VRRP-MIB $(DESTDIR)/usr/share/snmp/mibs/
-	cp -f doc/KEEPALIVED-MIB $(DESTDIR)/usr/share/snmp/mibs/
+	mkdir -p $(DESTDIR)@prefix@/share/snmp/mibs/
+	cp -f doc/VRRP-MIB $(DESTDIR)@prefix@/share/snmp/mibs/
+	cp -f doc/KEEPALIVED-MIB $(DESTDIR)@prefix@/share/snmp/mibs/
 endif
 
 tarball: mrproper
EOF
}

CONFIGURE_ARGS='			\
	--enable-snmp			\
	--enable-sha1			\
'
