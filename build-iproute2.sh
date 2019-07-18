#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=iproute2
PKG_VERSION=5.2.0
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://www.kernel.org/pub/linux/utils/net/iproute2/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=0cb2736e7bc2f56254a363d3d23703b7
PKG_DEPENDS='db elfutils libmnl'
PKG_PLATFORM=linux

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# - fail fast on installation failure
	patch -p1 <<"EOF"
--- a/Makefile.orig	2019-07-18 11:31:12.827598663 +0000
+++ b/Makefile	2019-07-18 11:31:42.270537771 +0000
@@ -37,6 +37,7 @@ DEFINES+= -DNO_SHARED_LIBS
 endif
 
 DEFINES+=-DCONFDIR=\"$(CONFDIR)\" \
+	 -DARPDDIR=\"$(ARPDDIR)\" \
          -DNETNS_RUN_DIR=\"$(NETNS_RUN_DIR)\" \
          -DNETNS_ETC_DIR=\"$(NETNS_ETC_DIR)\"
 
@@ -92,7 +93,7 @@ install: all
 		$(DESTDIR)$(DOCDIR)/examples
 	install -m 0644 $(shell find examples/diffserv -maxdepth 1 -type f) \
 		$(DESTDIR)$(DOCDIR)/examples/diffserv
-	@for i in $(SUBDIRS);  do $(MAKE) -C $$i install; done
+	@set -e; for i in $(SUBDIRS);  do $(MAKE) -C $$i install; done
 	install -m 0644 $(shell find etc/iproute2 -maxdepth 1 -type f) $(DESTDIR)$(CONFDIR)
 	install -m 0755 -d $(DESTDIR)$(BASH_COMPDIR)
 	install -m 0644 bash-completion/tc $(DESTDIR)$(BASH_COMPDIR)
--- a/misc/arpd.c.orig	2017-06-11 09:02:38.769871128 +0800
+++ b/misc/arpd.c	2017-06-11 09:02:43.077872476 +0800
@@ -39,7 +39,7 @@
 #include "rt_names.h"
 
 DB	*dbase;
-char	*dbname = "/var/lib/arpd/arpd.db";
+char	*dbname = ARPDDIR "/arpd.db";
 
 int	ifnum;
 int	*ifvec;
EOF
}

# the hand-written configure script expects $1 to be appended to gcc -I option.
# We need the following hack to let it find header files and libraries at
# $INSTALL_PREFIX
CONFIGURE_ARGS=(
	"$PKG_SOURCE_DIR/include ${EXTRA_CFLAGS[*]} ${EXTRA_LDFLAGS[*]}"
	"${CONFIGURE_ARGS[@]}"
)

MAKE_VARS+=(
	PREFIX="$INSTALL_PREFIX"
	SBINDIR="$INSTALL_PREFIX/sbin"
	CONFDIR="$INSTALL_PREFIX/etc/iproute2"
	ARPDDIR="$INSTALL_PREFIX/var/lib/arpd"
)
