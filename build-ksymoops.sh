#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=ksymoops
PKG_VERSION=2.4.9
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.gz"
PKG_SOURCE_URL="https://www.kernel.org/pub/linux/utils/kernel/ksymoops/v${PKG_VERSION%.*}/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=ed828814fdef8dc985d82b8acb915ae2
PKG_DEPENDS="zlib"
PKG_PLATFORM=linux

. "$PWD/env.sh"

configure() {
	:
}

MAKE_VARS+=(
	INSTALL_PREFIX="$INSTALL_PREFIX"
)

do_patch() {
	# packages
	#
	# 	binutils-devel		libbfd.a, libiberty.a
	#
	# Link option
	#
	#	-static			complete static linking, no shared library at all
	#	-Wl,-Bstatic		static linking specified libraries that follow
	#	-Wl,-Bdynamic		dynamic linking specified libraries that follow
	#
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- Makefile.orig	2019-09-11 07:31:40.580938307 +0000
+++ Makefile	2019-09-11 07:36:29.500983195 +0000
@@ -108,14 +108,14 @@ all: $(PROGS)
 $(OBJECTS): $(DEFS)
 
 $(PROGS): %: %.o $(DEFS) $(OBJECTS)
-	$(CC) $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(STATIC) -lbfd -liberty $(DYNAMIC) -o $@
+	$(CC) $(OBJECTS) $(CFLAGS) $(LDFLAGS) -static -lbfd -liberty -lz -ldl -o $@
 	-@size $@
 
 clean:
 	rm -f core *.o $(PROGS)
 
 install: all
-	$(INSTALL) -d $(INSTALL_PREFIX)/bin
-	$(INSTALL) ksymoops $(INSTALL_PREFIX)/bin/$(CROSS)ksymoops
-	$(INSTALL) -d $(INSTALL_MANDIR)/man8
-	$(INSTALL) ksymoops.8 $(INSTALL_MANDIR)/man8/$(CROSS)ksymoops.8
+	$(INSTALL) -d $(DESTDIR)$(INSTALL_PREFIX)/bin
+	$(INSTALL) ksymoops $(DESTDIR)$(INSTALL_PREFIX)/bin/$(CROSS)ksymoops
+	$(INSTALL) -d $(DESTDIR)$(INSTALL_MANDIR)/man8
+	$(INSTALL) ksymoops.8 $(DESTDIR)$(INSTALL_MANDIR)/man8/$(CROSS)ksymoops.8
EOF
}
