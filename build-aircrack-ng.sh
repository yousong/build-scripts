#!/bin/sh -e

PKG_NAME=aircrack-ng
PKG_VERSION=master
PKG_SOURCE="$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="http://download.aircrack-ng.org/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=
PKG_DEPENDS=openssl

. "$PWD/env.sh"

if os_is_linux; then
	PKG_DEPENDS="$PKG_DEPENDS libnl3"
fi

do_patch() {
	cd "$PKG_BUILD_DIR"

	# 1. include header detected header file first
	# 2. include src/pcap.h instead of the one from system headers
	patch -p0 <<"EOF"
--- common.mak.orig	2016-01-27 12:13:33.730905612 +0800
+++ common.mak	2016-01-27 12:14:55.742929210 +0800
@@ -205,7 +205,7 @@ endif
 
 CXXFLAGS	= $(CFLAGS) $(ASMFLAG) -fdata-sections -ffunction-sections
 
-CFLAGS          += $(OPTFLAGS) $(REVFLAGS) $(COMMON_CFLAGS)
+CFLAGS          := $(OPTFLAGS) $(REVFLAGS) $(COMMON_CFLAGS) $(CFLAGS) -g -O0
 
 prefix          = /usr/local
 bindir          = $(prefix)/bin
--- src/osdep/Makefile.orig	2016-01-27 12:13:33.730905612 +0800
+++ src/osdep/Makefile	2016-01-27 12:14:55.742929210 +0800
@@ -4,7 +4,7 @@
 RTAP		= radiotap
 
 LIB		= libosdep.a 
-CFLAGS		+= $(PIC) -I.. $(LIBAIRPCAP)
+CFLAGS		:= $(PIC) -I.. $(LIBAIRPCAP) $(CFLAGS)
 
 OBJS_COMMON	= network.o file.o
 OBJS		= osdep.o $(OBJS_COMMON)
EOF
}

configure() {
	true
}

MAKE_VARS="prefix='$INSTALL_PREFIX'"

# XXX, remove this on aircrack-ng 3
staging_pre() {
	local old="$MAKE_VARS"
	MAKE_VARS="prefix='$INSTALL_PREFIX' check"
	compile
	MAKE_VARS="$old"
}
