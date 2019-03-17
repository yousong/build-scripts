#!/bin/bash -e
#
# Copyright 2019 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
PKG_NAME=openipmi
PKG_VERSION=2.0.27
PKG_SOURCE="OpenIPMI-$PKG_VERSION.tar.gz"
PKG_SOURCE_URL="https://downloads.sourceforge.net/$PKG_NAME/OpenIPMI%202.0%20Library/$PKG_SOURCE"
PKG_SOURCE_MD5SUM=d525ceaa07df5440674e7e68a6772fe7
PKG_DEPENDS='ncurses libedit net-snmp openssl pcre popt readline zlib'
PKG_AUTOCONF_FIXUP=1

. "$PWD/env.sh"

do_patch() {
	cd "$PKG_SOURCE_DIR"
	patch -p0 <<"EOF"
--- cmdlang/Makefile.am.orig	2019-03-17 03:24:59.459829332 +0000
+++ cmdlang/Makefile.am	2019-03-17 03:25:10.027831937 +0000
@@ -35,6 +35,7 @@ openipmish_LDADD =  libOpenIPMIcmdlang.l
 # compatability.
 install-data-local:
 	rm -f $(DESTDIR)$(bindir)/ipmish
+	mkdir -p $(DESTDIR)$(bindir)
 	$(LN_S) openipmish $(DESTDIR)$(bindir)/ipmish
 
 uninstall-local:
EOF
}

CONFIGURE_ARGS+=(
	--with-perl=no
	--with-python=no
	--with-swig=no
	--with-tcl=no
	--with-glib=no
)
