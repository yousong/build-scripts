#!/bin/sh -e
#
# Copyright 2017 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=iproute2
PKG_VERSION=4.11.0
PKG_SOURCE="$PKG_NAME-${PKG_VERSION}.tar.xz"
PKG_SOURCE_URL="https://www.kernel.org/pub/linux/utils/net/iproute2/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=7a9498de88bcca95c305df6108ae197e
PKG_DEPENDS='db libelf libmnl'
PKG_PLATFORM=linux

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"

	# - install binaries to $INSTALL_PREFIX while keep using global configs at
	#   /etc/iproute2
	# - fail fast on installation failure
	patch -p1 <<"EOF"
diff --git a/Makefile b/Makefile
index 18de7dcb..761f7ba6 100644
--- a/Makefile
+++ b/Makefile
@@ -9,7 +9,7 @@ ifeq ($(VERBOSE),0)
 
 PREFIX?=/usr
 LIBDIR?=$(PREFIX)/lib
-SBINDIR?=/sbin
+SBINDIR?=$(PREFIX)/sbin
 CONFDIR?=/etc/iproute2
 DATADIR?=$(PREFIX)/share
 HDRDIR?=$(PREFIX)/include/iproute2
@@ -81,7 +82,7 @@ install: all
 		$(DESTDIR)$(DOCDIR)/examples
 	install -m 0644 $(shell find examples/diffserv -maxdepth 1 -type f) \
 		$(DESTDIR)$(DOCDIR)/examples/diffserv
-	@for i in $(SUBDIRS) doc; do $(MAKE) -C $$i install; done
+	@set -e; for i in $(SUBDIRS) doc; do $(MAKE) -C $$i install; done
 	install -m 0644 $(shell find etc/iproute2 -maxdepth 1 -type f) $(DESTDIR)$(CONFDIR)
 	install -m 0755 -d $(DESTDIR)$(BASH_COMPDIR)
 	install -m 0644 bash-completion/tc $(DESTDIR)$(BASH_COMPDIR)
EOF
}

# the hand-written configure script expects $1 to be appended to gcc -I option.
# We need the following hack to let it find header files and libraries at
# $INSTALL_PREFIX
CONFIGURE_ARGS=" \\
	'$PKG_SOURCE_DIR/include $EXTRA_CFLAGS $EXTRA_LDFLAGS' \\
"

MAKE_VARS="$MAKE_VARS		\\
	PREFIX=$INSTALL_PREFIX	\\
"
